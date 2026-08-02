Class {
	#name : 'REOccurrenceRegistration',
	#superclass : 'Object',
	#instVars : [
		'origin',
		'nextOccurrence'
	],
	#category : 'RecurringEvents-Engine',
	#package : 'RecurringEvents-Engine'
}

{ #category : 'ston' }
REOccurrenceRegistration class >> fromStonString: aString [
	^ STON fromString: aString
]

{ #category : 'instance creation' }
REOccurrenceRegistration class >> origin: anOrigin nextOccurrence: aDateAndTime [
	^ self new origin: anOrigin nextOccurrence: aDateAndTime
]

{ #category : 'ston' }
REOccurrenceRegistration >> asStonString [
	^ STON toString: self
]

{ #category : 'accessing' }
REOccurrenceRegistration >> nextOccurrence [
	^ nextOccurrence
]

{ #category : 'accessing' }
REOccurrenceRegistration >> origin [
	^ origin
]

{ #category : 'accessing' }
REOccurrenceRegistration >> origin: anOrigin nextOccurrence: aDateAndTime [
	origin := anOrigin.
	nextOccurrence := aDateAndTime
]

{ #category : 'printing' }
REOccurrenceRegistration >> printOn: aStream [
	aStream
		nextPutAll: (String with: $().
	origin printOn: aStream.
	aStream nextPutAll: ' next='.
	nextOccurrence printOn: aStream.
	aStream nextPutAll: (String with: $))
]
