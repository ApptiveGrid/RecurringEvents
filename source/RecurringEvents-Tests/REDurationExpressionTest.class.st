Class {
	#name : 'REDurationExpressionTest',
	#superclass : 'TestCase',
	#category : 'RecurringEvents-Tests',
	#package : 'RecurringEvents-Tests'
}

{ #category : 'tests' }
REDurationExpressionTest >> testExcludesBeforeStart [
	| start expr |
	start := DateAndTime year: 2026 month: 1 day: 1.
	expr := REDurationExpression new duration: (Duration days: 7).
	expr instVarNamed: #start put: start.
	self deny: (expr includes: start - (Duration days: 7))
]

{ #category : 'tests' }
REDurationExpressionTest >> testExcludesNonMultiple [
	| start expr |
	start := DateAndTime year: 2026 month: 1 day: 1.
	expr := REDurationExpression new duration: (Duration days: 7).
	expr instVarNamed: #start put: start.
	self deny: (expr includes: start + (Duration days: 10))
]

{ #category : 'tests' }
REDurationExpressionTest >> testIncludesMultipleOfDuration [
	| start expr |
	start := DateAndTime year: 2026 month: 1 day: 1.
	expr := REDurationExpression new duration: (Duration days: 7).
	expr instVarNamed: #start put: start.
	self assert: (expr includes: start + (Duration days: 14))
]

{ #category : 'tests' }
REDurationExpressionTest >> testIncludesStart [
	| start expr |
	start := DateAndTime year: 2026 month: 1 day: 1.
	expr := REDurationExpression new duration: (Duration days: 7).
	expr instVarNamed: #start put: start.
	self assert: (expr includes: start)
]

{ #category : 'tests' }
REDurationExpressionTest >> testNextOccurrenceAdvancesByDuration [
	| start expr |
	start := DateAndTime year: 2026 month: 1 day: 1.
	expr := REDurationExpression new duration: (Duration days: 7).
	expr instVarNamed: #start put: start.
	self assert: (expr nextOccurrenceAfter: start) equals: start + (Duration days: 7)
]

{ #category : 'tests' }
REDurationExpressionTest >> testNextOccurrenceWithNilArgumentReturnsStart [
	| start expr |
	start := DateAndTime year: 2026 month: 1 day: 1.
	expr := REDurationExpression new duration: (Duration days: 7).
	expr instVarNamed: #start put: start.
	self assert: (expr nextOccurrenceAfter: nil) equals: start
]
