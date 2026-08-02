Class {
	#name : 'REDifferenceTemporalExpression',
	#superclass : 'RETemporalExpression',
	#instVars : [
		'included',
		'excluded'
	],
	#category : 'RecurringEvents-Common',
	#package : 'RecurringEvents-Common'
}

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
