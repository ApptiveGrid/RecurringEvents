Class {
	#name : 'REIntersectionTemporalExpression',
	#superclass : 'RETemporalExpression',
	#instVars : [
		'expressions'
	],
	#category : 'RecurringEvents-Common',
	#package : 'RecurringEvents-Common'
}

{ #category : 'accessing' }
REIntersectionTemporalExpression >> expressions [
	^ expressions
]

{ #category : 'accessing' }
REIntersectionTemporalExpression >> expressions: aCollection [
	expressions := aCollection
]

{ #category : 'testing' }
REIntersectionTemporalExpression >> includes: aDateAndTime [
	^ expressions allSatisfy: [ :each | each includes: aDateAndTime ]
]

{ #category : 'private' }
REIntersectionTemporalExpression >> maxNextOccurrenceAfter: aDateAndTime [
	"Answers the latest of each sub-expression's next occurrence after aDateAndTime, or nil if any sub-expression has no further occurrence."
	| result next |
	result := nil.
	expressions do: [ :each |
		next := each nextOccurrenceAfter: aDateAndTime.
		next ifNil: [ ^ nil ].
		(result isNil or: [ next > result ]) ifTrue: [ result := next ] ].
	^ result
]

{ #category : 'as yet unclassified' }
REIntersectionTemporalExpression >> nextOccurrenceAfter: aDateAndTime [
	| candidate |
	candidate := aDateAndTime.
	[ candidate := self maxNextOccurrenceAfter: candidate.
	  candidate notNil and: [ (self includes: candidate) not ] ] whileTrue.
	^ candidate
]

{ #category : 'printing' }
REIntersectionTemporalExpression >> printOn: aStream [
	aStream nextPutAll: (String with: $().
	expressions
		do: [ :each | each printOn: aStream ]
		separatedBy: [ aStream nextPutAll: ' and ' ].
	aStream nextPutAll: (String with: $))
]
