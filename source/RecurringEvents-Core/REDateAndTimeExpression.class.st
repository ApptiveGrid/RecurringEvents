Class {
	#name : 'REDateAndTimeExpression',
	#superclass : 'RETemporalExpression',
	#instVars : [
		'dateAndTime'
	],
	#category : 'RecurringEvents-Core',
	#package : 'RecurringEvents-Core'
}

{ #category : 'accessing' }
REDateAndTimeExpression >> dateAndTime: anObject [
	dateAndTime := anObject
]

{ #category : 'testing' }
REDateAndTimeExpression >> includes: aDateAndTime [
	^ dateAndTime = aDateAndTime
]

{ #category : 'as yet unclassified' }
REDateAndTimeExpression >> nextOccurrenceAfter: aDateAndTime [
	^ aDateAndTime
		ifNotNil: [ nil ]
		ifNil: [ dateAndTime ]
]

{ #category : 'printing' }
REDateAndTimeExpression >> printOn: aStream [
	aStream
		nextPutAll: 'at ';
		nextPutAll: dateAndTime asString
]
