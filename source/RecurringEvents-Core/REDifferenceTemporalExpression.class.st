Class {
	#name : 'REDifferenceTemporalExpression',
	#superclass : 'RETemporalExpression',
	#instVars : [
		'included',
		'excluded'
	],
	#category : 'RecurringEvents-Core',
	#package : 'RecurringEvents-Core'
}

{ #category : 'json' }
REDifferenceTemporalExpression class >> fromJsonDict: aDict [
	^ self new
		included: (RETemporalExpression fromJsonDict: (aDict at: 'included'));
		excluded: (RETemporalExpression fromJsonDict: (aDict at: 'excluded'));
		yourself
]

{ #category : 'json' }
REDifferenceTemporalExpression >> asJsonDict [
	^ Dictionary new
		at: 'type' put: 'difference';
		at: 'included' put: included asJsonDict;
		at: 'excluded' put: excluded asJsonDict;
		yourself
]

{ #category : 'accessing' }
REDifferenceTemporalExpression >> excluded [
	^ excluded
]

{ #category : 'accessing' }
REDifferenceTemporalExpression >> excluded: anExpression [
	excluded := anExpression
]

{ #category : 'accessing' }
REDifferenceTemporalExpression >> included [
	^ included
]

{ #category : 'accessing' }
REDifferenceTemporalExpression >> included: anExpression [
	included := anExpression
]

{ #category : 'testing' }
REDifferenceTemporalExpression >> includes: aDateAndTime [
	^ (included includes: aDateAndTime) and: [ (excluded includes: aDateAndTime) not ]
]

{ #category : 'as yet unclassified' }
REDifferenceTemporalExpression >> nextOccurrenceAfter: aDateAndTime [
	| candidate |
	candidate := included nextOccurrenceAfter: aDateAndTime.
	[ candidate notNil and: [ excluded includes: candidate ] ] whileTrue: [
		candidate := included nextOccurrenceAfter: candidate ].
	^ candidate
]

{ #category : 'printing' }
REDifferenceTemporalExpression >> printOn: aStream [
	aStream nextPutAll: (String with: $().
	included printOn: aStream.
	aStream nextPutAll: ' except '.
	excluded printOn: aStream.
	aStream nextPutAll: (String with: $))
]
