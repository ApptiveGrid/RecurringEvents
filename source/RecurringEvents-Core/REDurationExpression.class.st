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

{ #category : 'json' }
REDurationExpression class >> fromJsonDict: aDict [
	^ self new
		duration: (Duration fromISO8601Duration: (aDict at: 'every'));
		start: (DateAndTime fromString: (aDict at: 'start'));
		yourself
]

{ #category : 'json' }
REDurationExpression >> asJsonDict [
	^ Dictionary new
		at: 'type' put: 'duration';
		at: 'start' put: start asString;
		at: 'every' put: duration asISO8601Duration;
		yourself
]

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

{ #category : 'accessing' }
REDurationExpression >> start [
	^ start
]

{ #category : 'accessing' }
REDurationExpression >> start: aDateAndTime [
	start := aDateAndTime
]
