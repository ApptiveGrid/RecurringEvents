Class {
	#name : 'RESetPositionExpressionTest',
	#superclass : 'TestCase',
	#category : 'RecurringEvents-Tests',
	#package : 'RecurringEvents-Tests'
}

{ #category : 'tests' }
RESetPositionExpressionTest >> testAppleExampleSecondAndLastWeekdayOfYear [
	"Apples own EKRecurrenceRule.setPositions doc example: weekdays + positions #(2 -1) ->
	2nd and last weekday of the year."
	| weekdays expr |
	weekdays := REDayInWeekExpression new weekdays: #(#Monday #Tuesday #Wednesday #Thursday #Friday).
	expr := RESetPositionExpression new candidate: weekdays period: #year positions: #(2 -1).
	self deny: (expr includes: (DateAndTime year: 2026 month: 1 day: 1)). "1st weekday (Thursday)"
	self assert: (expr includes: (DateAndTime year: 2026 month: 1 day: 2)). "2nd weekday (Friday)"
	self assert: (expr includes: (DateAndTime year: 2026 month: 12 day: 31)). "last weekday (Thursday)"
	self deny: (expr includes: (DateAndTime year: 2026 month: 12 day: 30))
]

{ #category : 'tests' }
RESetPositionExpressionTest >> testGeneralizesDayInMonthOrdinalMode [
	"More general than REDayInMonthExpressions built-in ordinal+weekday mode: same
	Thanksgiving result (4th Thursday of November), built from composable primitives instead
	of a dedicated ordinal field."
	| thursdaysInNovember expr |
	thursdaysInNovember := REIntersectionTemporalExpression new expressions: {
		(REDayInWeekExpression new weekdays: #(#Thursday)).
		(REMonthInYearExpression new months: #(#November)) }.
	expr := RESetPositionExpression new candidate: thursdaysInNovember period: #month positions: #(4).
	self assert: (expr includes: (DateAndTime year: 2026 month: 11 day: 26)).
	self deny: (expr includes: (DateAndTime year: 2026 month: 11 day: 19)).
	self assert: (expr nextOccurrenceAfter: (DateAndTime year: 2026 month: 11 day: 26)) equals: (DateAndTime year: 2027 month: 11 day: 25)
]

{ #category : 'tests' }
RESetPositionExpressionTest >> testLastWorkdayOfMonth [
	| weekdays expr |
	weekdays := REDayInWeekExpression new weekdays: #(#Monday #Tuesday #Wednesday #Thursday #Friday).
	expr := RESetPositionExpression new candidate: weekdays period: #month positions: #(-1).
	self assert: (expr includes: (DateAndTime year: 2026 month: 2 day: 27)). "Friday, last weekday before the Sat 28th"
	self deny: (expr includes: (DateAndTime year: 2026 month: 2 day: 28))
]

{ #category : 'tests' }
RESetPositionExpressionTest >> testNonCandidateDateIsExcludedRegardlessOfPosition [
	| weekdays expr |
	weekdays := REDayInWeekExpression new weekdays: #(#Monday).
	expr := RESetPositionExpression new candidate: weekdays period: #month positions: #(1 2 3 4 -1).
	self deny: (expr includes: (DateAndTime year: 2026 month: 8 day: 4)) "a Tuesday, never a candidate at all"
]

{ #category : 'tests' }
RESetPositionExpressionTest >> testPositionBeyondCandidateCountExcludesEveryDate [
	"Only 4 Thursdays in November 2026 - position 5 never matches, even on a Thursday."
	| thursdaysInNovember expr |
	thursdaysInNovember := REIntersectionTemporalExpression new expressions: {
		(REDayInWeekExpression new weekdays: #(#Thursday)).
		(REMonthInYearExpression new months: #(#November)) }.
	expr := RESetPositionExpression new candidate: thursdaysInNovember period: #month positions: #(5).
	self deny: (expr includes: (DateAndTime year: 2026 month: 11 day: 26)) "the 4th, and last, Thursday"
]
