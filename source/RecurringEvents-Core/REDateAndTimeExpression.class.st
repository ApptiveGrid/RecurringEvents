Class {
	#name : 'REDateAndTimeExpression',
	#superclass : 'RETemporalExpression',
	#instVars : [
		'dateAndTime'
	],
	#category : 'RecurringEvents-Core',
	#package : 'RecurringEvents-Core'
}

{ #category : 'json' }
REDateAndTimeExpression class >> fromJsonDict: aDict [
	^ self new dateAndTime: (DateAndTime fromString: (aDict at: 'at'))
]

{ #category : 'json' }
REDateAndTimeExpression >> asJsonDict [
	^ Dictionary new
		at: 'type' put: 'dateAndTime';
		at: 'at' put: dateAndTime asString;
		yourself
]

{ #category : 'accessing' }
REDateAndTimeExpression >> dateAndTime [
	^ dateAndTime
]

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
