Class {
	#name : 'REWeekInYearExpressionTest',
	#superclass : 'TestCase',
	#category : 'RecurringEvents-Tests',
	#package : 'RecurringEvents-Tests'
}

{ #category : 'tests' }
REWeekInYearExpressionTest >> testIncludesLastWeekOfA52WeekYear [
	| expr |
	expr := REWeekInYearExpression new weeks: #(-1).
	self assert: (expr includes: (DateAndTime year: 2025 month: 12 day: 28)). "2025 has only 52 ISO weeks"
	self deny: (expr includes: (DateAndTime year: 2025 month: 12 day: 29)) "already ISO week 1 of 2026"
]

{ #category : 'tests' }
REWeekInYearExpressionTest >> testIncludesLastWeekOfA53WeekYear [
	| expr |
	expr := REWeekInYearExpression new weeks: #(-1).
	self assert: (expr includes: (DateAndTime year: 2026 month: 12 day: 28)). "2026 has 53 ISO weeks"
	self deny: (expr includes: (DateAndTime year: 2026 month: 12 day: 21))
]

{ #category : 'tests' }
REWeekInYearExpressionTest >> testIncludesPositiveWeek [
	| expr |
	expr := REWeekInYearExpression new weeks: #(1 2).
	self assert: (expr includes: (DateAndTime year: 2026 month: 1 day: 1)). "ISO week 1 of 2026"
	self assert: (expr includes: (DateAndTime year: 2026 month: 1 day: 5)). "ISO week 2 of 2026"
	self deny: (expr includes: (DateAndTime year: 2026 month: 1 day: 12))
]

{ #category : 'tests' }
REWeekInYearExpressionTest >> testIsoWeekYearCanDifferFromCalendarYearAtBoundary [
	"Jan 1, 2027 belongs to ISO week 53 of 2026, not week 1 of 2027 - verified against
	Pythons datetime.isocalendar() as an independent oracle before writing this test."
	| expr |
	expr := REWeekInYearExpression new weeks: #(53).
	self assert: (expr includes: (DateAndTime year: 2027 month: 1 day: 1)).
	self deny: (REWeekInYearExpression new weeks: #(1); includes: (DateAndTime year: 2027 month: 1 day: 1))
]
