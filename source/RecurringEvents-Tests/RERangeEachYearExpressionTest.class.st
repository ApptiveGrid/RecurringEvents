Class {
	#name : 'RERangeEachYearExpressionTest',
	#superclass : 'TestCase',
	#category : 'RecurringEvents-Tests',
	#package : 'RecurringEvents-Tests'
}

{ #category : 'tests' }
RERangeEachYearExpressionTest >> testExcludesOutsideNonWrappingRange [
	| expr |
	expr := RERangeEachYearExpression new startMonth: 6 startDay: 1 endMonth: 8 endDay: 31.
	self deny: (expr includes: (DateAndTime year: 2026 month: 9 day: 1))
]

{ #category : 'tests' }
RERangeEachYearExpressionTest >> testExcludesOutsideWrappingRange [
	| expr |
	expr := RERangeEachYearExpression new startMonth: 12 startDay: 15 endMonth: 1 endDay: 15.
	self deny: (expr includes: (DateAndTime year: 2026 month: 2 day: 1))
]

{ #category : 'tests' }
RERangeEachYearExpressionTest >> testIncludesWithinNonWrappingRange [
	| expr |
	expr := RERangeEachYearExpression new startMonth: 6 startDay: 1 endMonth: 8 endDay: 31.
	self assert: (expr includes: (DateAndTime year: 2026 month: 7 day: 15))
]

{ #category : 'tests' }
RERangeEachYearExpressionTest >> testIncludesWithinWrappingRange [
	| expr |
	expr := RERangeEachYearExpression new startMonth: 12 startDay: 15 endMonth: 1 endDay: 15.
	self assert: (expr includes: (DateAndTime year: 2026 month: 12 day: 25)).
	self assert: (expr includes: (DateAndTime year: 2027 month: 1 day: 10))
]
