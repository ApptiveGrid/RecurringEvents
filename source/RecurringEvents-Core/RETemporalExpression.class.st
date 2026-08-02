Class {
	#name : 'RETemporalExpression',
	#superclass : 'Object',
	#category : 'RecurringEvents-Core',
	#package : 'RecurringEvents-Core'
}

{ #category : 'testing' }
RETemporalExpression >> includes: aDateAndTime [
	^ self subclassResponsibility
]

{ #category : 'accessing' }
RETemporalExpression >> nextOccurrence [
	^ self nextOccurrenceAfter: nil
]

{ #category : 'as yet unclassified' }
RETemporalExpression >> nextOccurrenceAfter: aDateAndTime [
	self subclassResponsibility
]
