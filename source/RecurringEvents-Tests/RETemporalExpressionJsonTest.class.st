Class {
	#name : 'RETemporalExpressionJsonTest',
	#superclass : 'TestCase',
	#category : 'RecurringEvents-Tests',
	#package : 'RecurringEvents-Tests'
}

{ #category : 'tests' }
RETemporalExpressionJsonTest >> testAbsoluteRangeRoundTrip [
	| expr roundtripped from to |
	from := DateAndTime year: 2026 month: 1 day: 1.
	to := DateAndTime year: 2026 month: 6 day: 1.
	expr := REAbsoluteRangeExpression new from: from to: to.
	roundtripped := RETemporalExpression fromJsonString: expr asJsonString.
	self assert: roundtripped class equals: REAbsoluteRangeExpression.
	self assert: (roundtripped includes: (DateAndTime year: 2026 month: 3 day: 1)).
	self deny: (roundtripped includes: to)
]

{ #category : 'tests' }
RETemporalExpressionJsonTest >> testAbsoluteRangeRoundTripWithOpenBound [
	| expr roundtripped from |
	from := DateAndTime year: 2026 month: 6 day: 1.
	expr := REAbsoluteRangeExpression new from: from to: nil.
	roundtripped := RETemporalExpression fromJsonString: expr asJsonString.
	self assert: roundtripped from equals: from.
	self assert: roundtripped to equals: nil
]

{ #category : 'tests' }
RETemporalExpressionJsonTest >> testDateAndTimeRoundTrip [
	| expr roundtripped date |
	date := DateAndTime year: 2026 month: 8 day: 2.
	expr := REDateAndTimeExpression new dateAndTime: date.
	roundtripped := RETemporalExpression fromJsonString: expr asJsonString.
	self assert: roundtripped class equals: REDateAndTimeExpression.
	self assert: (roundtripped includes: date).
	self deny: (roundtripped includes: date + (Duration days: 1))
]

{ #category : 'tests' }
RETemporalExpressionJsonTest >> testDayInMonthDayModeRoundTrip [
	| expr roundtripped |
	expr := REDayInMonthExpression new day: -1.
	roundtripped := RETemporalExpression fromJsonString: expr asJsonString.
	self assert: roundtripped class equals: REDayInMonthExpression.
	self assert: (roundtripped includes: (DateAndTime year: 2026 month: 8 day: 31)).
	self deny: (roundtripped includes: (DateAndTime year: 2026 month: 8 day: 30))
]

{ #category : 'tests' }
RETemporalExpressionJsonTest >> testDayInMonthOrdinalModeRoundTrip [
	| expr roundtripped |
	expr := REDayInMonthExpression new ordinal: 4 weekday: #Thursday.
	roundtripped := RETemporalExpression fromJsonString: expr asJsonString.
	self assert: roundtripped class equals: REDayInMonthExpression.
	self assert: (roundtripped includes: (DateAndTime year: 2026 month: 11 day: 26)).
	self deny: (roundtripped includes: (DateAndTime year: 2026 month: 11 day: 19))
]

{ #category : 'tests' }
RETemporalExpressionJsonTest >> testDayInWeekRoundTrip [
	| expr roundtripped |
	expr := REDayInWeekExpression new weekdays: #(#Monday #Wednesday).
	roundtripped := RETemporalExpression fromJsonString: expr asJsonString.
	self assert: roundtripped class equals: REDayInWeekExpression.
	self assert: (roundtripped includes: (DateAndTime year: 2026 month: 8 day: 3)).
	self deny: (roundtripped includes: (DateAndTime year: 2026 month: 8 day: 4))
]

{ #category : 'tests' }
RETemporalExpressionJsonTest >> testDifferenceRoundTrip [
	| every2 every3 base diff roundtripped |
	base := DateAndTime year: 2026 month: 1 day: 1.
	every2 := REDurationExpression new duration: (Duration days: 2); start: base; yourself.
	every3 := REDurationExpression new duration: (Duration days: 3); start: base; yourself.
	diff := REDifferenceTemporalExpression new included: every2; excluded: every3; yourself.
	roundtripped := RETemporalExpression fromJsonString: diff asJsonString.
	self assert: roundtripped class equals: REDifferenceTemporalExpression.
	self assert: (roundtripped includes: base + (Duration days: 2)).
	self deny: (roundtripped includes: base + (Duration days: 6))
]

{ #category : 'tests' }
RETemporalExpressionJsonTest >> testDurationRoundTrip [
	| expr roundtripped start |
	start := DateAndTime year: 2026 month: 1 day: 1.
	expr := REDurationExpression new duration: (Duration days: 7); start: start; yourself.
	roundtripped := RETemporalExpression fromJsonString: expr asJsonString.
	self assert: roundtripped class equals: REDurationExpression.
	self assert: (roundtripped includes: start + (Duration days: 14)).
	self deny: (roundtripped includes: start + (Duration days: 10))
]

{ #category : 'tests' }
RETemporalExpressionJsonTest >> testIntersectionRoundTrip [
	| every2 every3 base inter roundtripped |
	base := DateAndTime year: 2026 month: 1 day: 1.
	every2 := REDurationExpression new duration: (Duration days: 2); start: base; yourself.
	every3 := REDurationExpression new duration: (Duration days: 3); start: base; yourself.
	inter := REIntersectionTemporalExpression new expressions: { every2. every3 }.
	roundtripped := RETemporalExpression fromJsonString: inter asJsonString.
	self assert: roundtripped class equals: REIntersectionTemporalExpression.
	self assert: (roundtripped includes: base + (Duration days: 6)).
	self deny: (roundtripped includes: base + (Duration days: 3))
]

{ #category : 'tests' }
RETemporalExpressionJsonTest >> testIntervalRoundTrip [
	| start expr roundtripped |
	start := DateAndTime year: 2026 month: 1 day: 1.
	expr := REIntervalExpression new start: start unit: #month interval: 3.
	roundtripped := RETemporalExpression fromJsonString: expr asJsonString.
	self assert: roundtripped class equals: REIntervalExpression.
	self assert: (roundtripped includes: (DateAndTime year: 2026 month: 4 day: 1)).
	self deny: (roundtripped includes: (DateAndTime year: 2026 month: 2 day: 1))
]

{ #category : 'tests' }
RETemporalExpressionJsonTest >> testMonthInYearRoundTrip [
	| expr roundtripped |
	expr := REMonthInYearExpression new months: #(#June #July #August).
	roundtripped := RETemporalExpression fromJsonString: expr asJsonString.
	self assert: roundtripped class equals: REMonthInYearExpression.
	self assert: (roundtripped includes: (DateAndTime year: 2026 month: 7 day: 15)).
	self deny: (roundtripped includes: (DateAndTime year: 2026 month: 9 day: 1))
]

{ #category : 'tests' }
RETemporalExpressionJsonTest >> testRangeEachYearRoundTrip [
	| expr roundtripped |
	expr := RERangeEachYearExpression new startMonth: 12 startDay: 15 endMonth: 1 endDay: 15.
	roundtripped := RETemporalExpression fromJsonString: expr asJsonString.
	self assert: roundtripped class equals: RERangeEachYearExpression.
	self assert: (roundtripped includes: (DateAndTime year: 2026 month: 12 day: 25)).
	self deny: (roundtripped includes: (DateAndTime year: 2026 month: 2 day: 1))
]

{ #category : 'tests' }
RETemporalExpressionJsonTest >> testThanksgivingRoundTrip [
	"Fowler's own worked example, round-tripped through JSON to validate the format
	handles real compositions, not just single nodes."
	| november fourthThursday thanksgiving roundtripped |
	november := REMonthInYearExpression new months: #(#November).
	fourthThursday := REDayInMonthExpression new ordinal: 4 weekday: #Thursday.
	thanksgiving := REIntersectionTemporalExpression new expressions: { november. fourthThursday }.
	roundtripped := RETemporalExpression fromJsonString: thanksgiving asJsonString.
	self assert: (roundtripped includes: (DateAndTime year: 2026 month: 11 day: 26)).
	self deny: (roundtripped includes: (DateAndTime year: 2026 month: 11 day: 19))
]

{ #category : 'tests' }
RETemporalExpressionJsonTest >> testUnionRoundTrip [
	| every2 every3 base union roundtripped |
	base := DateAndTime year: 2026 month: 1 day: 1.
	every2 := REDurationExpression new duration: (Duration days: 2); start: base; yourself.
	every3 := REDurationExpression new duration: (Duration days: 3); start: base; yourself.
	union := REUnionTemporalExpression new expressions: { every2. every3 }.
	roundtripped := RETemporalExpression fromJsonString: union asJsonString.
	self assert: roundtripped class equals: REUnionTemporalExpression.
	self assert: (roundtripped includes: base + (Duration days: 2)).
	self deny: (roundtripped includes: base + (Duration days: 1))
]

{ #category : 'tests' }
RETemporalExpressionJsonTest >> testUnknownTypeRaisesError [
	self should: [ RETemporalExpression fromJsonDict: (Dictionary new at: 'type' put: 'bogus'; yourself) ]
		raise: Error
]
