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

{ #category : 'rrule' }
RETemporalExpression class >> applyExceptions: aBaseExpression exdates: exdateCollection rdates: rdateCollection [
	| result |
	result := aBaseExpression.
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

{ #category : 'icalendar' }
RETemporalExpression class >> extractICalendarExceptionsFrom: anExpression [
	"Inverse of applyExceptions:exdates:rdates: - returns {ruleExpression. exdates. rdates}."
	| current exdates rdates |
	current := anExpression.
	rdates := OrderedCollection new.
	(current isKindOf: REUnionTemporalExpression) ifTrue: [
		| subs |
		subs := current expressions.
		(subs size > 1 and: [ (subs allButFirst) allSatisfy: [ :e | e isKindOf: REDateAndTimeExpression ] ]) ifTrue: [
			rdates addAll: (subs allButFirst collect: [ :e | e dateAndTime ]).
			current := subs first ] ].
	exdates := OrderedCollection new.
	(current isKindOf: REDifferenceTemporalExpression) ifTrue: [
		| excluded |
		excluded := current excluded.
		(excluded isKindOf: REDateAndTimeExpression) ifTrue: [
			exdates add: excluded dateAndTime.
			current := current included ].
		((excluded isKindOf: REUnionTemporalExpression) and: [ excluded expressions allSatisfy: [ :e | e isKindOf: REDateAndTimeExpression ] ]) ifTrue: [
			exdates addAll: (excluded expressions collect: [ :e | e dateAndTime ]).
			current := current included ] ].
	^ { current. exdates. rdates }
]

{ #category : 'icalendar' }
RETemporalExpression class >> formatICalendarDateTime: aDateAndTime [
	^ String streamContents: [ :s |
		s
			print: aDateAndTime year;
			nextPutAll: (self twoDigits: aDateAndTime month);
			nextPutAll: (self twoDigits: aDateAndTime dayOfMonth);
			nextPutAll: 'T';
			nextPutAll: (self twoDigits: aDateAndTime hour);
			nextPutAll: (self twoDigits: aDateAndTime minute);
			nextPutAll: (self twoDigits: aDateAndTime second truncated) ]
]

{ #category : 'icalendar' }
RETemporalExpression class >> fromICalendarString: aString [
	"Parses a full .ics text blob (a bare VEVENT block, or a whole VCALENDAR containing one -
	any VTIMEZONE/other surrounding components are ignored) into our tree. Uses only the first
	VEVENT found; RecurringEvents models one recurring rule, not a whole calendar."
	| lines beginIndex endIndex dtstart rruleValue exdates rdates base |
	lines := (self unfoldICalendarLines: aString) asArray.
	beginIndex := lines indexOf: 'BEGIN:VEVENT'.
	beginIndex = 0 ifTrue: [ self error: 'No VEVENT block found' ].
	endIndex := lines indexOf: 'END:VEVENT' startingAt: beginIndex.
	endIndex = 0 ifTrue: [ self error: 'VEVENT block has no END:VEVENT' ].

	dtstart := nil. rruleValue := nil.
	exdates := OrderedCollection new.
	rdates := OrderedCollection new.
	(beginIndex + 1 to: endIndex - 1) do: [ :i |
		| parsed name value |
		parsed := self parseICalendarPropertyLine: (lines at: i).
		name := parsed first. value := parsed second.
		name = 'DTSTART' ifTrue: [ dtstart := self parseICalendarDateTime: value ].
		name = 'RRULE' ifTrue: [ rruleValue := value ].
		name = 'EXDATE' ifTrue: [ exdates addAll: ((value substrings: ',') collect: [ :v | self parseICalendarDateTime: v ]) ].
		name = 'RDATE' ifTrue: [ rdates addAll: ((value substrings: ',') collect: [ :v | self parseICalendarDateTime: v ]) ] ].

	dtstart ifNil: [ self error: 'VEVENT has no DTSTART' ].
	base := rruleValue
		ifNotNil: [ self fromRRuleString: rruleValue dtstart: dtstart ]
		ifNil: [ REDateAndTimeExpression new dateAndTime: dtstart ].
	^ self applyExceptions: base exdates: exdates rdates: rdates
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
	^ self applyExceptions: (self fromRRuleString: aString dtstart: aDateAndTime) exdates: exdateCollection rdates: rdateCollection
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

{ #category : 'icalendar' }
RETemporalExpression class >> parseICalendarDateTime: aString [
	"Parses a DATE (YYYYMMDD) or DATE-TIME (YYYYMMDDTHHMMSS[Z]) value into a naive DateAndTime -
	the trailing Z (UTC marker) and any TZID parameter are both ignored, same naive-datetime
	stance as the rest of this library (see backlog)."
	| s |
	s := (aString notEmpty and: [ aString last = $Z ])
		ifTrue: [ aString copyFrom: 1 to: aString size - 1 ]
		ifFalse: [ aString ].
	s size = 8 ifTrue: [
		^ DateAndTime year: (s copyFrom: 1 to: 4) asInteger month: (s copyFrom: 5 to: 6) asInteger day: (s copyFrom: 7 to: 8) asInteger ].
	^ DateAndTime
		year: (s copyFrom: 1 to: 4) asInteger month: (s copyFrom: 5 to: 6) asInteger day: (s copyFrom: 7 to: 8) asInteger
		hour: (s copyFrom: 10 to: 11) asInteger minute: (s copyFrom: 12 to: 13) asInteger second: (s copyFrom: 14 to: 15) asInteger
]

{ #category : 'icalendar' }
RETemporalExpression class >> parseICalendarPropertyLine: aLine [
	"Returns {NAME (uppercase, params stripped). VALUE}. Ignores parameters (e.g. TZID) - we
	only ever parse the naive date/time components, consistent with the rest of this library
	not handling timezones at all (see backlog)."
	| colonIndex head value semicolonIndex name |
	colonIndex := aLine indexOf: $:.
	head := aLine copyFrom: 1 to: colonIndex - 1.
	value := aLine copyFrom: colonIndex + 1 to: aLine size.
	semicolonIndex := head indexOf: $;.
	name := semicolonIndex = 0 ifTrue: [ head ] ifFalse: [ head copyFrom: 1 to: semicolonIndex - 1 ].
	^ { name asUppercase. value }
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

{ #category : 'rrule-vendor' }
RETemporalExpression class >> rruleByDayEntryCountIn: parts [
	(parts includesKey: 'BYDAY') ifFalse: [ ^ 0 ].
	^ ((parts at: 'BYDAY') substrings: ',') size
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

{ #category : 'icalendar' }
RETemporalExpression class >> unfoldICalendarLines: aString [
	"RFC 5545 content-line folding: a line may be split across multiple physical lines, where
	every continuation line starts with a single space or tab that must be stripped and joined
	to the previous line. Real files use CRLF; tolerate bare LF too."
	| normalized physicalLines result |
	normalized := aString copyReplaceAll: (String with: Character cr with: Character lf) with: (String with: Character lf).
	normalized := normalized copyReplaceAll: (String with: Character cr) with: (String with: Character lf).
	physicalLines := normalized substrings: (String with: Character lf).
	result := OrderedCollection new.
	physicalLines do: [ :line |
		(line notEmpty and: [ (line first = Character space) or: [ line first = Character tab ] ])
			ifTrue: [ result at: result size put: (result last , (line copyFrom: 2 to: line size)) ]
			ifFalse: [ result add: line ] ].
	^ result
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

{ #category : 'icalendar' }
RETemporalExpression >> asICalendarStringWithUid: aUidString dtstamp: aDtstamp dtstart: aDtstart [
	"A complete, standalone minimal .ics file (VCALENDAR wrapper around the VEVENT block)."
	| crlf |
	crlf := String with: Character cr with: Character lf.
	^ String streamContents: [ :s |
		s
			nextPutAll: 'BEGIN:VCALENDAR'; nextPutAll: crlf;
			nextPutAll: 'VERSION:2.0'; nextPutAll: crlf;
			nextPutAll: 'PRODID:-//RecurringEvents//EN'; nextPutAll: crlf;
			nextPutAll: (self asICalendarVEventStringWithUid: aUidString dtstamp: aDtstamp dtstart: aDtstart); nextPutAll: crlf;
			nextPutAll: 'END:VCALENDAR' ]
]

{ #category : 'icalendar' }
RETemporalExpression >> asICalendarVEventStringWithUid: aUidString dtstamp: aDtstamp dtstart: aDtstart [
	| extracted ruleExpr exdates rdates lines crlf |
	extracted := self class extractICalendarExceptionsFrom: self.
	ruleExpr := extracted first. exdates := extracted second. rdates := extracted third.
	lines := OrderedCollection new.
	lines add: 'BEGIN:VEVENT'.
	lines add: 'UID:' , aUidString.
	lines add: 'DTSTAMP:' , (self class formatICalendarDateTime: aDtstamp).
	lines add: 'DTSTART:' , (self class formatICalendarDateTime: aDtstart).
	lines add: 'RRULE:' , ruleExpr asRRuleString.
	exdates ifNotEmpty: [
		lines add: 'EXDATE:' , ((exdates collect: [ :d | self class formatICalendarDateTime: d ]) inject: '' into: [ :a :b | a isEmpty ifTrue: [ b ] ifFalse: [ a , ',' , b ] ]) ].
	rdates ifNotEmpty: [
		lines add: 'RDATE:' , ((rdates collect: [ :d | self class formatICalendarDateTime: d ]) inject: '' into: [ :a :b | a isEmpty ifTrue: [ b ] ifFalse: [ a , ',' , b ] ]) ].
	lines add: 'END:VEVENT'.
	crlf := String with: Character cr with: Character lf.
	^ String streamContents: [ :s | lines do: [ :l | s nextPutAll: l ] separatedBy: [ s nextPutAll: crlf ] ]
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
	| decomposed freqUnit interval wkst parts untilExpr orderedKeys |
	decomposed := self rruleComponents.
	freqUnit := decomposed first. interval := decomposed second. wkst := decomposed third.
	parts := decomposed fourth. untilExpr := decomposed fifth.

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

{ #category : 'rrule' }
RETemporalExpression >> rruleComponents [
	"Shared decomposition used by both asRRuleString and rruleWarningsFor: - returns
	{freqUnit. interval. wkst. parts (Dictionary of BYxxx-name -> value string). untilExpr or nil}."
	| components freqUnit interval wkst remaining untilExpr parts |
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
	^ { freqUnit. interval. wkst. parts. untilExpr }
]

{ #category : 'rrule-vendor' }
RETemporalExpression >> rruleWarningsFor: aVendorSymbol [
	"Advisory only - the RFC-faithful core (asRRuleString/asICalendarStringWithUid:dtstamp:dtstart:)
	stays unchanged and always produces valid RFC 5545 output regardless of these warnings.
	This just tells the caller which parts of THIS specific tree a given vendors own UI/API
	cannot natively create or fully support, based on the vendor research in the decisions doc -
	so callers can decide whether to warn a user, pick a different composition, or proceed anyway
	knowing the resulting event may end up not fully editable in that vendors calendar app."
	| decomposed freqUnit wkst parts warnings byDayCount |
	decomposed := self rruleComponents.
	freqUnit := decomposed first. wkst := decomposed third. parts := decomposed fourth.
	warnings := OrderedCollection new.
	byDayCount := self class rruleByDayEntryCountIn: parts.

	(parts includesKey: 'BYSETPOS') ifTrue: [
		byDayCount > 1
			ifTrue: [
				aVendorSymbol = #google ifTrue: [ warnings add: 'Google Calendar accepts BYSETPOS combined with multiple BYDAY weekdays on import, but its own UI cannot create or edit such a series (edit-lock risk).' ].
				aVendorSymbol = #apple ifTrue: [ warnings add: 'Apple EventKit supports generic multi-weekday BYSETPOS at the API level (EKRecurrenceRule.setPositions), but Calendar.app''s UI can only author single-weekday ordinal patterns, not this one.' ].
				aVendorSymbol = #outlook ifTrue: [ warnings add: 'Outlook/Microsoft Graph has no generic BYSETPOS equivalent - its relativeMonthly pattern only supports a single day-of-week selection (multiple BYDAY values would only use the first match). This rule cannot be represented correctly for Outlook.' ] ]
			ifFalse: [
				aVendorSymbol = #outlook ifTrue: [ "single-weekday BYSETPOS/ordinal BYDAY is fine - Outlook's relativeMonthly index+daysOfWeek covers exactly this case" ] ] ].

	((parts includesKey: 'BYYEARDAY') or: [ parts includesKey: 'BYWEEKNO' ]) ifTrue: [
		| featureName |
		featureName := (parts includesKey: 'BYYEARDAY') ifTrue: [ 'BYYEARDAY' ] ifFalse: [ 'BYWEEKNO' ].
		aVendorSymbol = #google ifTrue: [ warnings add: featureName , ' has no Google Calendar UI support - importable, but not creatable or editable there.' ].
		aVendorSymbol = #apple ifTrue: [ warnings add: featureName , ' is API-only in Apple EventKit (daysOfTheYear/weeksOfTheYear, yearly only) - no Calendar.app UI path to author or edit it.' ].
		aVendorSymbol = #outlook ifTrue: [ warnings add: featureName , ' has no equivalent at all in Outlook/Microsoft Graph - this rule cannot be represented for Outlook interop.' ] ].

	(freqUnit = #week and: [ wkst ~= #Monday and: [ byDayCount > 1 ] ]) ifTrue: [
		aVendorSymbol = #google ifTrue: [ warnings add: 'Google Calendar does not expose or apply a non-default WKST - a multi-weekday weekly INTERVAL rule with WKST ~= Monday may be interpreted differently there (or simply not be UI-editable as authored).' ].
		aVendorSymbol = #apple ifTrue: [ warnings add: 'Apple EventKits firstDayOfTheWeek is read-only - there is no way to author a non-default WKST via the API at all, so this rule cannot be faithfully represented for Apple.' ] ].

	^ warnings
]
