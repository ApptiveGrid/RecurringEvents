Class {
	#name : 'REDayInMonthExpressionTest',
	#superclass : 'TestCase',
	#category : 'RecurringEvents-Tests',
	#package : 'RecurringEvents-Tests'
}

{ #category : 'tests' }
REDayInMonthExpressionTest >> testDayModeMatchesGivenDayNumber [
	| expr |
	expr := REDayInMonthExpression new day: 1.
	self assert: (expr includes: (DateAndTime year: 2026 month: 8 day: 1)).
	self deny: (expr includes: (DateAndTime year: 2026 month: 8 day: 2))
]

{ #category : 'tests' }
REDayInMonthExpressionTest >> testDayModeSupportsNegativeCountingFromMonthEnd [
	"August 2026 has 31 days."
	| expr |
	expr := REDayInMonthExpression new day: -1.
	self assert: (expr includes: (DateAndTime year: 2026 month: 8 day: 31)).
	self deny: (expr includes: (DateAndTime year: 2026 month: 8 day: 30))
]

{ #category : 'tests' }
REDayInMonthExpressionTest >> testOrdinalWeekdayModeMatchesNthWeekday [
	"Thanksgiving 2026: the 4th Thursday of November is November 26."
	| expr |
	expr := REDayInMonthExpression new ordinal: 4 weekday: #Thursday.
	self assert: (expr includes: (DateAndTime year: 2026 month: 11 day: 26)).
	self deny: (expr includes: (DateAndTime year: 2026 month: 11 day: 19))
]

{ #category : 'tests' }
REDayInMonthExpressionTest >> testOrdinalWeekdayModeSupportsNegativeOrdinalFromMonthEnd [
	"Memorial Day 2026: the last Monday of May is May 25."
	| expr |
	expr := REDayInMonthExpression new ordinal: -1 weekday: #Monday.
	self assert: (expr includes: (DateAndTime year: 2026 month: 5 day: 25)).
	self deny: (expr includes: (DateAndTime year: 2026 month: 5 day: 18))
]
