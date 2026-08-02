Class {
	#name : 'REDateAndTimeExpressionTest',
	#superclass : 'TestCase',
	#category : 'RecurringEvents-Tests',
	#package : 'RecurringEvents-Tests'
}

{ #category : 'tests' }
REDateAndTimeExpressionTest >> testExcludesOtherMoment [
	| date expr |
	date := DateAndTime year: 2026 month: 8 day: 2.
	expr := REDateAndTimeExpression new dateAndTime: date.
	self deny: (expr includes: date + (Duration days: 1))
]

{ #category : 'tests' }
REDateAndTimeExpressionTest >> testIncludesExactMoment [
	| date expr |
	date := DateAndTime year: 2026 month: 8 day: 2.
	expr := REDateAndTimeExpression new dateAndTime: date.
	self assert: (expr includes: date)
]

{ #category : 'tests' }
REDateAndTimeExpressionTest >> testNextOccurrenceAfterAnyDateIsNil [
	| date expr |
	date := DateAndTime year: 2026 month: 8 day: 2.
	expr := REDateAndTimeExpression new dateAndTime: date.
	self assert: (expr nextOccurrenceAfter: date) isNil
]

{ #category : 'tests' }
REDateAndTimeExpressionTest >> testNextOccurrenceWithNilArgumentReturnsTheDate [
	| date expr |
	date := DateAndTime year: 2026 month: 8 day: 2.
	expr := REDateAndTimeExpression new dateAndTime: date.
	self assert: (expr nextOccurrenceAfter: nil) equals: date
]
