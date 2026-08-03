Class {
	#name : 'REAbsoluteRangeExpressionTest',
	#superclass : 'TestCase',
	#category : 'RecurringEvents-Tests',
	#package : 'RecurringEvents-Tests'
}

{ #category : 'tests' }
REAbsoluteRangeExpressionTest >> testIncludesWithinBothBounds [
	| expr from to |
	from := DateAndTime year: 2026 month: 1 day: 1.
	to := DateAndTime year: 2026 month: 6 day: 1.
	expr := REAbsoluteRangeExpression new from: from to: to.
	self assert: (expr includes: from).
	self assert: (expr includes: (DateAndTime year: 2026 month: 3 day: 15)).
	self deny: (expr includes: to). "to is exclusive"
	self deny: (expr includes: from - (Duration days: 1))
]

{ #category : 'tests' }
REAbsoluteRangeExpressionTest >> testNextOccurrenceBeforeFromJumpsToFrom [
	| expr from |
	from := DateAndTime year: 2026 month: 6 day: 1.
	expr := REAbsoluteRangeExpression new from: from to: nil.
	self assert: (expr nextOccurrenceAfter: from - (Duration days: 10)) equals: from
]

{ #category : 'tests' }
REAbsoluteRangeExpressionTest >> testNextOccurrenceReturnsNilOnceWindowIsClosed [
	| expr from to |
	from := DateAndTime year: 2026 month: 1 day: 1.
	to := DateAndTime year: 2026 month: 1 day: 3.
	expr := REAbsoluteRangeExpression new from: from to: to.
	self assert: (expr nextOccurrenceAfter: from) equals: from + (Duration days: 1).
	self assert: (expr nextOccurrenceAfter: to - (Duration days: 1)) equals: nil
]

{ #category : 'tests' }
REAbsoluteRangeExpressionTest >> testNextOccurrenceWithNilArgumentReturnsFrom [
	| expr from |
	from := DateAndTime year: 2026 month: 6 day: 1.
	expr := REAbsoluteRangeExpression new from: from to: nil.
	self assert: (expr nextOccurrenceAfter: nil) equals: from
]

{ #category : 'tests' }
REAbsoluteRangeExpressionTest >> testOpenLowerBound [
	| expr to |
	to := DateAndTime year: 2026 month: 6 day: 1.
	expr := REAbsoluteRangeExpression new from: nil to: to.
	self assert: (expr includes: (DateAndTime year: 1900 month: 1 day: 1)).
	self deny: (expr includes: to)
]

{ #category : 'tests' }
REAbsoluteRangeExpressionTest >> testOpenUpperBound [
	| expr from |
	from := DateAndTime year: 2026 month: 6 day: 1.
	expr := REAbsoluteRangeExpression new from: from to: nil.
	self assert: (expr includes: from).
	self assert: (expr includes: (DateAndTime year: 3000 month: 1 day: 1)).
	self deny: (expr includes: from - (Duration days: 1))
]

{ #category : 'tests' }
REAbsoluteRangeExpressionTest >> testSingleInstanceMoveNeedsNoNewPrimitive [
	"Roadmap point 5, half 2: moving a single occurrence (same event, different date) is
	already fully expressible with the existing Difference+Union+DateAndTime primitives -
	no new class needed for this half, unlike the this-and-future case above."
	| everyMonday movedDay untouchedDay withMove |
	everyMonday := REDayInWeekExpression new weekdays: #(#Monday).
	movedDay := DateAndTime year: 2026 month: 8 day: 10. "a Monday"
	untouchedDay := DateAndTime year: 2026 month: 8 day: 17. "the following Monday"
	withMove := REUnionTemporalExpression new expressions: {
		(REDifferenceTemporalExpression new included: everyMonday; excluded: (REDateAndTimeExpression new dateAndTime: movedDay); yourself).
		(REDateAndTimeExpression new dateAndTime: movedDay + (Duration days: 1)) }.
	self deny: (withMove includes: movedDay).
	self assert: (withMove includes: movedDay + (Duration days: 1)).
	self assert: (withMove includes: untouchedDay)
]

{ #category : 'tests' }
REAbsoluteRangeExpressionTest >> testThisAndFutureRuleChangeAtBoundary [
	"Roadmap point 5, half 1: change a series this-and-future without rebuilding
	the old rule - split into two Intersections clipped by an REAbsoluteRangeExpression,
	joined by Union. Mirrors what Google Calendar actually does (split the series),
	just expressed compositionally instead of by mutating an RRULE UNTIL."
	| oldRule newRule boundary combined |
	oldRule := REIntersectionTemporalExpression new expressions: {
		(REIntervalExpression new start: (DateAndTime year: 2026 month: 1 day: 1) unit: #month interval: 3).
		(REDayInMonthExpression new day: 1) }.
	newRule := REIntersectionTemporalExpression new expressions: {
		(REIntervalExpression new start: (DateAndTime year: 2026 month: 6 day: 1) unit: #month interval: 2).
		(REDayInMonthExpression new day: 15) }.
	boundary := DateAndTime year: 2026 month: 6 day: 1.
	combined := REUnionTemporalExpression new expressions: {
		(REIntersectionTemporalExpression new expressions: { oldRule. (REAbsoluteRangeExpression new from: nil to: boundary) }).
		(REIntersectionTemporalExpression new expressions: { newRule. (REAbsoluteRangeExpression new from: boundary to: nil) }) }.
	self assert: (combined includes: (DateAndTime year: 2026 month: 1 day: 1)). "old rule, before boundary"
	self assert: (combined includes: (DateAndTime year: 2026 month: 4 day: 1)). "old rule, before boundary"
	self deny: (combined includes: (DateAndTime year: 2026 month: 7 day: 1)). "old rule wouldve matched here, but its past the cutover"
	self assert: (combined includes: (DateAndTime year: 2026 month: 8 day: 15)). "new rule, from boundary on"
	self assert: (combined nextOccurrenceAfter: (DateAndTime year: 2026 month: 4 day: 1)) equals: (DateAndTime year: 2026 month: 6 day: 15)
]
