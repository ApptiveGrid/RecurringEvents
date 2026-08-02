Class {
	#name : 'REMonthInYearExpressionTest',
	#superclass : 'TestCase',
	#category : 'RecurringEvents-Tests',
	#package : 'RecurringEvents-Tests'
}

{ #category : 'tests' }
REMonthInYearExpressionTest >> testExcludesOtherMonth [
	| expr |
	expr := REMonthInYearExpression new months: #(#June #July #August).
	self deny: (expr includes: (DateAndTime year: 2026 month: 9 day: 1))
]

{ #category : 'tests' }
REMonthInYearExpressionTest >> testIncludesListedMonth [
	| expr |
	expr := REMonthInYearExpression new months: #(#June #July #August).
	self assert: (expr includes: (DateAndTime year: 2026 month: 7 day: 15))
]
