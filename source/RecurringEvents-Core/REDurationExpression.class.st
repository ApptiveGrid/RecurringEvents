Class {
	#name : 'REDurationExpression',
	#superclass : 'RETemporalExpression',
	#instVars : [
		'duration',
		'start'
	],
	#category : 'RecurringEvents-Core',
	#package : 'RecurringEvents-Core'
}

{ #category : 'accessing' }
REDurationExpression >> duration: anObject [
	duration := anObject
]

{ #category : 'testing' }
REDurationExpression >> includes: aDateAndTime [
	^ aDateAndTime >= start and: [ ((aDateAndTime - start) / duration) isInteger ]
]

{ #category : 'initialize' }
REDurationExpression >> initialize [
	super initialize.
	start := DateAndTime now rounded.
]

{ #category : 'accessing' }
REDurationExpression >> nextOccurrenceAfter: aDateAndTime [
	^ aDateAndTime
		ifNotNil: [ aDateAndTime + duration ]
		ifNil: [ start ]
]

{ #category : 'printing' }
REDurationExpression >> printOn: aStream [
	aStream
		nextPutAll: 'every ';
		nextPutAll: duration asString
]
