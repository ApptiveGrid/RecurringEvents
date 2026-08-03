Class {
	#name : 'RETemporalExpression',
	#superclass : 'Object',
	#category : 'RecurringEvents-Core',
	#package : 'RecurringEvents-Core'
}

{ #category : 'rrule' }
RETemporalExpression class >> addRRuleFilterPart: c to: parts [
	(c isKindOf: REDayInWeekExpression) ifTrue: [
		parts at: 'BYDAY' put: (self joinWithCommas: (c weekdays collect: [ :w | self rruleDayCodeFor: w ])).
		^ self ].
	(c isKindOf: REMonthInYearExpression) ifTrue: [
		parts at: 'BYMONTH' put: (self joinWithCommas: (c months collect: [ :m | (self monthNumberFor: m) printString ])).
		^ self ].
	(c isKindOf: REDayInYearExpression) ifTrue: [
		parts at: 'BYYEARDAY' put: (self joinWithCommas: (c days collect: [ :d | d printString ])).
		^ self ].
	(c isKindOf: REWeekInYearExpression) ifTrue: [
		parts at: 'BYWEEKNO' put: (self joinWithCommas: (c weeks collect: [ :w | w printString ])).
		^ self ].
	(c isKindOf: REDayInMonthExpression) ifTrue: [
		c day
			ifNotNil: [ parts at: 'BYMONTHDAY' put: c day printString ]
			ifNil: [ parts at: 'BYDAY' put: (self rruleOrdinalDayEntryFor: c ordinal weekday: c weekday) ].
		^ self ].
	(c isKindOf: REUnionTemporalExpression) ifTrue: [ ^ self addRRuleUnionPart: c to: parts ].
	(c isKindOf: RESetPositionExpression) ifTrue: [ ^ self addRRuleSetPositionPart: c to: parts ].
	self error: 'Cannot represent as RRULE: ' , c class name
]

{ #category : 'rrule' }
RETemporalExpression class >> addRRuleSetPositionPart: aSetPos to: parts [
	| candidateComponents |
	candidateComponents := (aSetPos candidate isKindOf: REIntersectionTemporalExpression)
		ifTrue: [ aSetPos candidate expressions ]
		ifFalse: [ { aSetPos candidate } ].
	candidateComponents do: [ :cc | self addRRuleFilterPart: cc to: parts ].
	parts at: 'BYSETPOS' put: (self joinWithCommas: (aSetPos positions collect: [ :p | p printString ]))
]

{ #category : 'rrule' }
RETemporalExpression class >> addRRuleUnionPart: aUnion to: parts [
	| subs |
	subs := aUnion expressions.
	(subs allSatisfy: [ :e | (e isKindOf: REDayInMonthExpression) and: [ e day notNil ] ]) ifTrue: [
		parts at: 'BYMONTHDAY' put: (self joinWithCommas: (subs collect: [ :e | e day printString ])).
		^ self ].
	(subs allSatisfy: [ :e | e isKindOf: RESetPositionExpression ]) ifTrue: [
		parts at: 'BYDAY' put: (self joinWithCommas: (subs collect: [ :e | self rruleOrdinalByDayEntryFor: e ])).
		^ self ].
	self error: 'Cannot represent this Union as RRULE'
]

{ #category : 'json' }
RETemporalExpression class >> fromJsonDict: aDict [
	| type |
	type := aDict at: 'type'.
	type = 'dateAndTime' ifTrue: [ ^ REDateAndTimeExpression fromJsonDict: aDict ].
	type = 'duration' ifTrue: [ ^ REDurationExpression fromJsonDict: aDict ].
	type = 'dayInWeek' ifTrue: [ ^ REDayInWeekExpression fromJsonDict: aDict ].
	type = 'monthInYear' ifTrue: [ ^ REMonthInYearExpression fromJsonDict: aDict ].
	type = 'dayInMonth' ifTrue: [ ^ REDayInMonthExpression fromJsonDict: aDict ].
	type = 'rangeEachYear' ifTrue: [ ^ RERangeEachYearExpression fromJsonDict: aDict ].
	type = 'interval' ifTrue: [ ^ REIntervalExpression fromJsonDict: aDict ].
	type = 'absoluteRange' ifTrue: [ ^ REAbsoluteRangeExpression fromJsonDict: aDict ].
	type = 'setPosition' ifTrue: [ ^ RESetPositionExpression fromJsonDict: aDict ].
	type = 'dayInYear' ifTrue: [ ^ REDayInYearExpression fromJsonDict: aDict ].
	type = 'weekInYear' ifTrue: [ ^ REWeekInYearExpression fromJsonDict: aDict ].
	type = 'union' ifTrue: [ ^ REUnionTemporalExpression fromJsonDict: aDict ].
	type = 'intersection' ifTrue: [ ^ REIntersectionTemporalExpression fromJsonDict: aDict ].
	type = 'difference' ifTrue: [ ^ REDifferenceTemporalExpression fromJsonDict: aDict ].
	self error: 'Unknown RecurringEvents JSON type: ' , type
]

{ #category : 'json' }
RETemporalExpression class >> fromJsonString: aString [
	^ self fromJsonDict: (NeoJSONReader fromString: aString)
]

{ #category : 'rrule' }
RETemporalExpression class >> fromRRuleString: aString dtstart: aDateAndTime [
	| parts freqUnit interval wkst subExpressions plainWeekdays ordinalPairs otherFilterForSetPos monthFilter needsMonthScopedPeriod effectivePeriod |
	parts := self parseRRuleParts: aString.
	(parts includesKey: 'COUNT') ifTrue: [ self error: 'RRULE COUNT is not yet supported' ].
	freqUnit := self unitForRRuleFreq: (parts at: 'FREQ').
	interval := (parts at: 'INTERVAL' ifAbsent: [ '1' ]) asInteger.
	wkst := (parts includesKey: 'WKST') ifTrue: [ self weekdayForRRuleDayCode: (parts at: 'WKST') ] ifFalse: [ #Monday ].

	subExpressions := OrderedCollection new.
	subExpressions add: (REIntervalExpression new start: aDateAndTime unit: freqUnit interval: interval; wkst: wkst; yourself).

	plainWeekdays := OrderedCollection new.
	ordinalPairs := OrderedCollection new.
	(parts includesKey: 'BYDAY') ifTrue: [
		((parts at: 'BYDAY') substrings: ',') do: [ :entry |
			| parsed |
			parsed := self parseByDayEntry: entry.
			parsed first ifNil: [ plainWeekdays add: parsed second ] ifNotNil: [ ordinalPairs add: parsed ] ] ].

	monthFilter := (parts includesKey: 'BYMONTH')
		ifTrue: [
			| monthNums monthSymbols |
			monthNums := ((parts at: 'BYMONTH') substrings: ',') collect: [ :s | s asInteger ].
			monthSymbols := (monthNums collect: [ :n | #(#January #February #March #April #May #June #July #August #September #October #November #December) at: n ]) asArray.
			REMonthInYearExpression new months: monthSymbols ]
		ifFalse: [ nil ].

	needsMonthScopedPeriod := freqUnit = #year
		and: [ monthFilter notNil
		and: [ ordinalPairs notEmpty or: [ parts includesKey: 'BYSETPOS' ] ] ].
	effectivePeriod := needsMonthScopedPeriod ifTrue: [ #month ] ifFalse: [ freqUnit ].

	ordinalPairs isEmpty ifFalse: [
		| unionOfPairs |
		unionOfPairs := (ordinalPairs collect: [ :pair |
			| weekdayExpr candidate |
			weekdayExpr := REDayInWeekExpression new weekdays: { pair second }.
			candidate := needsMonthScopedPeriod
				ifTrue: [ REIntersectionTemporalExpression new expressions: { weekdayExpr. monthFilter } ]
				ifFalse: [ weekdayExpr ].
			RESetPositionExpression new candidate: candidate period: effectivePeriod positions: { pair first } ]) asArray.
		subExpressions add: (unionOfPairs size = 1 ifTrue: [ unionOfPairs first ] ifFalse: [ REUnionTemporalExpression new expressions: unionOfPairs ]) ].

	otherFilterForSetPos := OrderedCollection new.
	plainWeekdays isEmpty ifFalse: [ otherFilterForSetPos add: (REDayInWeekExpression new weekdays: plainWeekdays asArray) ].
	(parts includesKey: 'BYMONTHDAY') ifTrue: [
		| days union |
		days := ((parts at: 'BYMONTHDAY') substrings: ',') collect: [ :s | s asInteger ].
		union := (days collect: [ :d | REDayInMonthExpression new day: d ]) asArray.
		otherFilterForSetPos add: (union size = 1 ifTrue: [ union first ] ifFalse: [ REUnionTemporalExpression new expressions: union ]) ].
	monthFilter ifNotNil: [
		(needsMonthScopedPeriod and: [ ordinalPairs notEmpty ]) ifFalse: [ otherFilterForSetPos add: monthFilter ] ].
	(parts includesKey: 'BYYEARDAY') ifTrue: [
		| vals |
		vals := (((parts at: 'BYYEARDAY') substrings: ',') collect: [ :s | s asInteger ]) asArray.
		otherFilterForSetPos add: (REDayInYearExpression new days: vals) ].
	(parts includesKey: 'BYWEEKNO') ifTrue: [
		| vals |
		vals := (((parts at: 'BYWEEKNO') substrings: ',') collect: [ :s | s asInteger ]) asArray.
		otherFilterForSetPos add: (REWeekInYearExpression new weeks: vals) ].

	(parts includesKey: 'BYSETPOS')
		ifTrue: [
			| positions combinedFilter |
			positions := (((parts at: 'BYSETPOS') substrings: ',') collect: [ :s | s asInteger ]) asArray.
			combinedFilter := otherFilterForSetPos size = 1
				ifTrue: [ otherFilterForSetPos first ]
				ifFalse: [ REIntersectionTemporalExpression new expressions: otherFilterForSetPos asArray ].
			subExpressions add: (RESetPositionExpression new candidate: combinedFilter period: effectivePeriod positions: positions) ]
		ifFalse: [ subExpressions addAll: otherFilterForSetPos ].

	subExpressions size = 1 ifTrue: [
		"RFC 5545: with no BYxxx day-selector at all, the recurrence defaults to DTSTARTs own
		weekday/day-of-month/day-of-year, NOT every day of the FREQ period."
		freqUnit = #week ifTrue: [ subExpressions add: (REDayInWeekExpression new weekdays: { aDateAndTime dayOfWeekName }) ].
		freqUnit = #month ifTrue: [ subExpressions add: (REDayInMonthExpression new day: aDateAndTime dayOfMonth) ].
		freqUnit = #year ifTrue: [ subExpressions add: (REDayInYearExpression new days: { aDateAndTime dayOfYear }) ] ].

	(parts includesKey: 'UNTIL') ifTrue: [
		subExpressions add: (REAbsoluteRangeExpression new from: nil to: (self untilExclusiveBoundFor: (parts at: 'UNTIL'))) ].

	^ subExpressions size = 1
		ifTrue: [ subExpressions first ]
		ifFalse: [ REIntersectionTemporalExpression new expressions: subExpressions asArray ]
]

{ #category : 'rrule' }
RETemporalExpression class >> fromRRuleString: aString dtstart: aDateAndTime exdates: exdateCollection rdates: rdateCollection [
	"EXDATE/RDATE are their own VEVENT properties, not part of the RRULE string - map them onto
	our existing Difference/Union primitives at the top level, exactly as noted in the roadmap
	(no new class needed for this, unlike the RRULE value itself)."
	| result |
	result := self fromRRuleString: aString dtstart: aDateAndTime.
	(exdateCollection notNil and: [ exdateCollection notEmpty ]) ifTrue: [
		| excluded |
		excluded := exdateCollection size = 1
			ifTrue: [ REDateAndTimeExpression new dateAndTime: exdateCollection first ]
			ifFalse: [ REUnionTemporalExpression new expressions: (exdateCollection collect: [ :d | REDateAndTimeExpression new dateAndTime: d ]) asArray ].
		result := REDifferenceTemporalExpression new included: result; excluded: excluded; yourself ].
	(rdateCollection notNil and: [ rdateCollection notEmpty ]) ifTrue: [
		| extra |
		extra := (rdateCollection collect: [ :d | REDateAndTimeExpression new dateAndTime: d ]) asArray.
		result := REUnionTemporalExpression new expressions: ({ result } , extra) ].
	^ result
]

{ #category : 'rrule' }
RETemporalExpression class >> inferRRuleFreqUnitFor: remaining [
	remaining do: [ :c |
		(c isKindOf: RESetPositionExpression) ifTrue: [ ^ c period ].
		((c isKindOf: REUnionTemporalExpression) and: [ c expressions notEmpty and: [ c expressions first isKindOf: RESetPositionExpression ] ])
			ifTrue: [ ^ c expressions first period ].
		(c isKindOf: REDayInWeekExpression) ifTrue: [ ^ #week ].
		(c isKindOf: REDayInMonthExpression) ifTrue: [ ^ #month ].
		((c isKindOf: REDayInYearExpression) or: [ (c isKindOf: REWeekInYearExpression) or: [ c isKindOf: REMonthInYearExpression ] ])
			ifTrue: [ ^ #year ] ].
	self error: 'Cannot infer RRULE FREQ - no REIntervalExpression and no recognizable calendar filter'
]

{ #category : 'rrule' }
RETemporalExpression class >> joinWithCommas: aCollectionOfStrings [
	^ aCollectionOfStrings inject: '' into: [ :a :b | a isEmpty ifTrue: [ b ] ifFalse: [ a , ',' , b ] ]
]

{ #category : 'json' }
RETemporalExpression class >> jsonNameFor: aSymbol [
	^ aSymbol asString asLowercase
]

{ #category : 'rrule' }
RETemporalExpression class >> monthNumberFor: aMonthSymbol [
	^ #(#January #February #March #April #May #June #July #August #September #October #November #December) indexOf: aMonthSymbol
]

{ #category : 'rrule' }
RETemporalExpression class >> parseByDayEntry: aString [
	"Returns an Array {ordinalOrNil. weekdaySymbol}. aString is e.g. 'MO', '-1FR', '4TH'."
	| code ordinalPart |
	code := aString last: 2.
	ordinalPart := aString copyFrom: 1 to: aString size - 2.
	^ { ordinalPart isEmpty ifTrue: [ nil ] ifFalse: [ ordinalPart asInteger ]. self weekdayForRRuleDayCode: code }
]

{ #category : 'rrule' }
RETemporalExpression class >> parseRRuleParts: aString [
	"Parses semicolon-separated NAME=VALUE pairs into a Dictionary keyed by NAME (uppercase)."
	| result |
	result := Dictionary new.
	(aString substrings: ';') do: [ :part |
		| eq |
		eq := part indexOf: $=.
		result
			at: (part copyFrom: 1 to: eq - 1) asUppercase
			put: (part copyFrom: eq + 1 to: part size) ].
	^ result
]

{ #category : 'rrule' }
RETemporalExpression class >> rruleDayCodeFor: aWeekdaySymbol [
	^ (Dictionary new
		at: #Monday put: 'MO'; at: #Tuesday put: 'TU'; at: #Wednesday put: 'WE';
		at: #Thursday put: 'TH'; at: #Friday put: 'FR'; at: #Saturday put: 'SA'; at: #Sunday put: 'SU';
		yourself) at: aWeekdaySymbol
]

{ #category : 'rrule' }
RETemporalExpression class >> rruleFilterPartsFor: aCollection [
	| parts |
	parts := Dictionary new.
	aCollection do: [ :c | self addRRuleFilterPart: c to: parts ].
	^ parts
]

{ #category : 'rrule' }
RETemporalExpression class >> rruleFreqFor: aUnitSymbol [
	aUnitSymbol = #week ifTrue: [ ^ 'WEEKLY' ].
	aUnitSymbol = #month ifTrue: [ ^ 'MONTHLY' ].
	aUnitSymbol = #year ifTrue: [ ^ 'YEARLY' ].
	self error: 'Cannot represent unit as RRULE FREQ: ' , aUnitSymbol
]

{ #category : 'rrule' }
RETemporalExpression class >> rruleOrdinalByDayEntryFor: aSetPos [
	| candidate weekdayExpr ordinal |
	aSetPos positions size = 1 ifFalse: [ self error: 'Cannot represent multi-position BYSETPOS as ordinal BYDAY' ].
	ordinal := aSetPos positions first.
	candidate := aSetPos candidate.
	weekdayExpr := (candidate isKindOf: REDayInWeekExpression)
		ifTrue: [ candidate ]
		ifFalse: [
			(candidate isKindOf: REIntersectionTemporalExpression)
				ifTrue: [ candidate expressions detect: [ :e | e isKindOf: REDayInWeekExpression ] ifNone: [ self error: 'Cannot decode ordinal BYDAY candidate' ] ]
				ifFalse: [ self error: 'Cannot decode ordinal BYDAY candidate' ] ].
	weekdayExpr weekdays size = 1 ifFalse: [ self error: 'Ordinal BYDAY candidate must be a single weekday' ].
	^ self rruleOrdinalDayEntryFor: ordinal weekday: weekdayExpr weekdays first
]

{ #category : 'rrule' }
RETemporalExpression class >> rruleOrdinalDayEntryFor: anOrdinal weekday: aWeekdaySymbol [
	^ anOrdinal printString , (self rruleDayCodeFor: aWeekdaySymbol)
]

{ #category : 'rrule' }
RETemporalExpression class >> rruleUntilStringFor: exclusiveBound [
	| inclusiveInstant |
	inclusiveInstant := exclusiveBound - (Duration seconds: 1).
	^ String streamContents: [ :s |
		s
			print: inclusiveInstant year;
			nextPutAll: (self twoDigits: inclusiveInstant month);
			nextPutAll: (self twoDigits: inclusiveInstant dayOfMonth);
			nextPutAll: 'T';
			nextPutAll: (self twoDigits: inclusiveInstant hour);
			nextPutAll: (self twoDigits: inclusiveInstant minute);
			nextPutAll: (self twoDigits: inclusiveInstant second truncated);
			nextPutAll: 'Z' ]
]

{ #category : 'json' }
RETemporalExpression class >> symbolForJsonName: aString [
	^ (aString first asUppercase asString , aString allButFirst) asSymbol
]

{ #category : 'rrule' }
RETemporalExpression class >> twoDigits: anInteger [
	^ anInteger < 10 ifTrue: [ '0' , anInteger printString ] ifFalse: [ anInteger printString ]
]

{ #category : 'rrule' }
RETemporalExpression class >> unitForRRuleFreq: aFreqString [
	aFreqString = 'WEEKLY' ifTrue: [ ^ #week ].
	aFreqString = 'MONTHLY' ifTrue: [ ^ #month ].
	aFreqString = 'YEARLY' ifTrue: [ ^ #year ].
	self error: 'Unsupported RRULE FREQ (only WEEKLY/MONTHLY/YEARLY): ' , aFreqString
]

{ #category : 'rrule' }
RETemporalExpression class >> untilExclusiveBoundFor: aString [
	"RRULE UNTIL is either a DATE (YYYYMMDD, inclusive through end of that day) or a
	UTC DATE-TIME (YYYYMMDDTHHMMSSZ, inclusive of that exact instant). Returns the
	corresponding EXCLUSIVE upper bound for REAbsoluteRangeExpressions to: parameter."
	| year month day dateOnly |
	year := (aString copyFrom: 1 to: 4) asInteger.
	month := (aString copyFrom: 5 to: 6) asInteger.
	day := (aString copyFrom: 7 to: 8) asInteger.
	dateOnly := aString size = 8.
	dateOnly ifTrue: [ ^ (DateAndTime year: year month: month day: day) + (Duration days: 1) ].
	^ (DateAndTime
		year: year month: month day: day
		hour: (aString copyFrom: 10 to: 11) asInteger
		minute: (aString copyFrom: 12 to: 13) asInteger
		second: (aString copyFrom: 14 to: 15) asInteger) + (Duration seconds: 1)
]

{ #category : 'rrule' }
RETemporalExpression class >> weekdayForRRuleDayCode: aTwoLetterString [
	^ (Dictionary new
		at: 'MO' put: #Monday; at: 'TU' put: #Tuesday; at: 'WE' put: #Wednesday;
		at: 'TH' put: #Thursday; at: 'FR' put: #Friday; at: 'SA' put: #Saturday; at: 'SU' put: #Sunday;
		yourself) at: aTwoLetterString
]

{ #category : 'json' }
RETemporalExpression >> asJsonDict [
	^ self subclassResponsibility
]

{ #category : 'json' }
RETemporalExpression >> asJsonString [
	^ NeoJSONWriter toString: self asJsonDict
]

{ #category : 'rrule' }
RETemporalExpression >> asRRuleString [
	| components freqUnit interval wkst remaining untilExpr parts orderedKeys |
	components := (self class = REIntersectionTemporalExpression)
		ifTrue: [ self expressions asOrderedCollection ]
		ifFalse: [ OrderedCollection with: self ].

	freqUnit := nil. interval := 1. wkst := #Monday.
	remaining := OrderedCollection new.
	untilExpr := nil.
	components do: [ :c |
		(c isKindOf: REIntervalExpression)
			ifTrue: [ freqUnit := c unit. interval := c interval. wkst := c wkst ]
			ifFalse: [
				(c isKindOf: REAbsoluteRangeExpression)
					ifTrue: [ untilExpr := c ]
					ifFalse: [ remaining add: c ] ] ].

	parts := self class rruleFilterPartsFor: remaining.
	freqUnit ifNil: [ freqUnit := self class inferRRuleFreqUnitFor: remaining ].

	orderedKeys := #('BYMONTH' 'BYWEEKNO' 'BYYEARDAY' 'BYMONTHDAY' 'BYDAY' 'BYSETPOS').
	^ String streamContents: [ :s |
		s nextPutAll: 'FREQ='; nextPutAll: (self class rruleFreqFor: freqUnit).
		interval = 1 ifFalse: [ s nextPutAll: ';INTERVAL='; print: interval ].
		wkst = #Monday ifFalse: [ s nextPutAll: ';WKST='; nextPutAll: (self class rruleDayCodeFor: wkst) ].
		orderedKeys do: [ :k | (parts includesKey: k) ifTrue: [ s nextPutAll: ';' , k , '=' , (parts at: k) ] ].
		untilExpr ifNotNil: [ s nextPutAll: ';UNTIL='; nextPutAll: (self class rruleUntilStringFor: untilExpr to) ] ]
]

{ #category : 'testing' }
RETemporalExpression >> includes: aDateAndTime [
	^ self subclassResponsibility
]

{ #category : 'accessing' }
RETemporalExpression >> nextOccurrence [
	^ self nextOccurrenceAfter: nil
]

{ #category : 'as yet unclassified' }
RETemporalExpression >> nextOccurrenceAfter: aDateAndTime [
	self subclassResponsibility
]
