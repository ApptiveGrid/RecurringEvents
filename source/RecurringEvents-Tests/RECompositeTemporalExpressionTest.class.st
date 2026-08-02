Class {
	#name : 'RECompositeTemporalExpressionTest',
	#superclass : 'TestCase',
	#category : 'RecurringEvents-Tests',
	#package : 'RecurringEvents-Tests'
}

{ #category : 'tests' }
RECompositeTemporalExpressionTest >> testDifferenceExcludesOverlap [
	| every2 every3 base diff |
	base := DateAndTime year: 2026 month: 1 day: 1.
	every2 := REDurationExpression new duration: (Duration days: 2).
	every2 instVarNamed: #start put: base.
	every3 := REDurationExpression new duration: (Duration days: 3).
	every3 instVarNamed: #start put: base.
	diff := REDifferenceTemporalExpression new included: every2; excluded: every3; yourself.
	self assert: (diff includes: base + (Duration days: 2)).
	self deny: (diff includes: base + (Duration days: 6))
]

{ #category : 'tests' }
RECompositeTemporalExpressionTest >> testDifferenceNextOccurrenceSkipsExcludedOccurrences [
	"After day 4 the next multiple of 2 is day 6, but day 6 is also a multiple of 3
	(excluded), so the difference must skip forward to day 8."
	| every2 every3 base diff |
	base := DateAndTime year: 2026 month: 1 day: 1.
	every2 := REDurationExpression new duration: (Duration days: 2).
	every2 instVarNamed: #start put: base.
	every3 := REDurationExpression new duration: (Duration days: 3).
	every3 instVarNamed: #start put: base.
	diff := REDifferenceTemporalExpression new included: every2; excluded: every3; yourself.
	self assert: (diff nextOccurrenceAfter: base + (Duration days: 4)) equals: base + (Duration days: 8)
]

{ #category : 'tests' }
RECompositeTemporalExpressionTest >> testIntersectionNextOccurrenceSkipsUntilConsistent [
	| every2 every3 base inter |
	base := DateAndTime year: 2026 month: 1 day: 1.
	every2 := REDurationExpression new duration: (Duration days: 2).
	every2 instVarNamed: #start put: base.
	every3 := REDurationExpression new duration: (Duration days: 3).
	every3 instVarNamed: #start put: base.
	inter := REIntersectionTemporalExpression new expressions: { every2. every3 }.
	self assert: (inter nextOccurrenceAfter: base) equals: base + (Duration days: 6)
]

{ #category : 'tests' }
RECompositeTemporalExpressionTest >> testIntersectionOnlyIncludesCommonOccurrences [
	"Every 2 days intersected with every 3 days only lands on common multiples (LCM = 6)."
	| every2 every3 base inter |
	base := DateAndTime year: 2026 month: 1 day: 1.
	every2 := REDurationExpression new duration: (Duration days: 2).
	every2 instVarNamed: #start put: base.
	every3 := REDurationExpression new duration: (Duration days: 3).
	every3 instVarNamed: #start put: base.
	inter := REIntersectionTemporalExpression new expressions: { every2. every3 }.
	self assert: (inter includes: base + (Duration days: 6)).
	self deny: (inter includes: base + (Duration days: 3))
]

{ #category : 'tests' }
RECompositeTemporalExpressionTest >> testMemorialDayComposesMonthAndNegativeOrdinalWeekday [
	"Memorial Day is the last Monday of May, expressed via a negative ordinal."
	| may lastMonday memorialDay |
	may := REMonthInYearExpression new months: #(#May).
	lastMonday := REDayInMonthExpression new ordinal: -1 weekday: #Monday.
	memorialDay := REIntersectionTemporalExpression new expressions: { may. lastMonday }.
	self assert: (memorialDay includes: (DateAndTime year: 2026 month: 5 day: 25)).
	self deny: (memorialDay includes: (DateAndTime year: 2026 month: 5 day: 18))
]

{ #category : 'tests' }
RECompositeTemporalExpressionTest >> testThanksgivingComposesMonthAndOrdinalWeekday [
	"Fowler's own worked example: Thanksgiving is the 4th Thursday of November,
	expressed as an Intersection of a month test and an ordinal-weekday test."
	| november fourthThursday thanksgiving |
	november := REMonthInYearExpression new months: #(#November).
	fourthThursday := REDayInMonthExpression new ordinal: 4 weekday: #Thursday.
	thanksgiving := REIntersectionTemporalExpression new expressions: { november. fourthThursday }.
	self assert: (thanksgiving includes: (DateAndTime year: 2026 month: 11 day: 26)).
	self deny: (thanksgiving includes: (DateAndTime year: 2026 month: 11 day: 19)).
	self deny: (thanksgiving includes: (DateAndTime year: 2026 month: 11 day: 27))
]

{ #category : 'tests' }
RECompositeTemporalExpressionTest >> testUnionIncludesEitherExpression [
	| every2 every3 base union |
	base := DateAndTime year: 2026 month: 1 day: 1.
	every2 := REDurationExpression new duration: (Duration days: 2).
	every2 instVarNamed: #start put: base.
	every3 := REDurationExpression new duration: (Duration days: 3).
	every3 instVarNamed: #start put: base.
	union := REUnionTemporalExpression new expressions: { every2. every3 }.
	self assert: (union includes: base + (Duration days: 2)).
	self assert: (union includes: base + (Duration days: 3)).
	self deny: (union includes: base + (Duration days: 1))
]

{ #category : 'tests' }
RECompositeTemporalExpressionTest >> testUnionNextOccurrenceIsEarliestAcrossExpressions [
	| every2 every3 base union |
	base := DateAndTime year: 2026 month: 1 day: 1.
	every2 := REDurationExpression new duration: (Duration days: 2).
	every2 instVarNamed: #start put: base.
	every3 := REDurationExpression new duration: (Duration days: 3).
	every3 instVarNamed: #start put: base.
	union := REUnionTemporalExpression new expressions: { every2. every3 }.
	self assert: (union nextOccurrenceAfter: base) equals: base + (Duration days: 2)
]
