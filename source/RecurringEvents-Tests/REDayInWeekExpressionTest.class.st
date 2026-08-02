Class {
	#name : 'REDayInWeekExpressionTest',
	#superclass : 'TestCase',
	#category : 'RecurringEvents-Tests',
	#package : 'RecurringEvents-Tests'
}

{ #category : 'tests' }
REDayInWeekExpressionTest >> testExcludesOtherWeekday [
	| expr |
	expr := REDayInWeekExpression new weekdays: #(#Monday #Wednesday).
	self deny: (expr includes: (DateAndTime year: 2026 month: 8 day: 4))
]

{ #category : 'tests' }
REDayInWeekExpressionTest >> testIncludesListedWeekday [
	"2026-08-03 is a Monday, 2026-08-04 a Tuesday."
	| expr |
	expr := REDayInWeekExpression new weekdays: #(#Monday #Wednesday).
	self assert: (expr includes: (DateAndTime year: 2026 month: 8 day: 3))
]

{ #category : 'tests' }
REDayInWeekExpressionTest >> testNextOccurrenceFindsNextMatchingWeekdayWithinAWeek [
	| expr monday |
	monday := DateAndTime year: 2026 month: 8 day: 3.
	expr := REDayInWeekExpression new weekdays: #(#Monday).
	self assert: (expr nextOccurrenceAfter: monday) equals: monday + (Duration days: 7)
]
