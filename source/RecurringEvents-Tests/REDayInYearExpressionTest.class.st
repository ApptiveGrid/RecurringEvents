Class {
	#name : 'REDayInYearExpressionTest',
	#superclass : 'TestCase',
	#category : 'RecurringEvents-Tests',
	#package : 'RecurringEvents-Tests'
}

{ #category : 'tests' }
REDayInYearExpressionTest >> testComposesWithIntervalForEveryOtherYearOnADayOfYear [
	"Roadmap point 3 motivation: BYYEARDAY combined with a calendar-aware yearly INTERVAL
	(roadmap point 1), e.g. every other year on day 100."
	| expr |
	expr := REIntersectionTemporalExpression new expressions: {
		(REIntervalExpression new start: (DateAndTime year: 2026 month: 1 day: 1) unit: #year interval: 2).
		(REDayInYearExpression new days: #(100)) }.
	self assert: (expr includes: (DateAndTime year: 2026 month: 4 day: 10)).
	self deny: (expr includes: (DateAndTime year: 2027 month: 4 day: 10))
]

{ #category : 'tests' }
REDayInYearExpressionTest >> testIncludesNegativeDayFromEndOfLeapYear [
	| expr |
	expr := REDayInYearExpression new days: #(-1).
	self assert: (expr includes: (DateAndTime year: 2024 month: 12 day: 31)). "2024 has 366 days"
	self deny: (expr includes: (DateAndTime year: 2024 month: 12 day: 30))
]

{ #category : 'tests' }
REDayInYearExpressionTest >> testIncludesNegativeDayFromEndOfNonLeapYear [
	| expr |
	expr := REDayInYearExpression new days: #(-1).
	self assert: (expr includes: (DateAndTime year: 2026 month: 12 day: 31)). "2026 has 365 days"
	self deny: (expr includes: (DateAndTime year: 2026 month: 12 day: 30))
]

{ #category : 'tests' }
REDayInYearExpressionTest >> testIncludesPositiveDay [
	| expr |
	expr := REDayInYearExpression new days: #(1 100).
	self assert: (expr includes: (DateAndTime year: 2026 month: 1 day: 1)).
	self assert: (expr includes: (DateAndTime year: 2026 month: 4 day: 10)).
	self deny: (expr includes: (DateAndTime year: 2026 month: 1 day: 2))
]
