Class {
	#name : 'REUnionTemporalExpression',
	#superclass : 'RETemporalExpression',
	#instVars : [
		'expressions'
	],
	#category : 'RecurringEvents-Core',
	#package : 'RecurringEvents-Core'
}

{ #category : 'json' }
REUnionTemporalExpression class >> fromJsonDict: aDict [
	^ self new expressions: ((aDict at: 'expressions') collect: [ :each | RETemporalExpression fromJsonDict: each ])
]

{ #category : 'json' }
REUnionTemporalExpression >> asJsonDict [
	^ Dictionary new
		at: 'type' put: 'union';
		at: 'expressions' put: (expressions collect: [ :each | each asJsonDict ]) asArray;
		yourself
]

{ #category : 'accessing' }
REUnionTemporalExpression >> expressions [
	^ expressions
]

{ #category : 'accessing' }
REUnionTemporalExpression >> expressions: aCollection [
	expressions := aCollection
]

{ #category : 'testing' }
REUnionTemporalExpression >> includes: aDateAndTime [
	^ expressions anySatisfy: [ :each | each includes: aDateAndTime ]
]

{ #category : 'as yet unclassified' }
REUnionTemporalExpression >> nextOccurrenceAfter: aDateAndTime [
	| candidates |
	candidates := (expressions collect: [ :each | each nextOccurrenceAfter: aDateAndTime ])
		reject: [ :each | each isNil ].
	^ candidates ifEmpty: [ nil ] ifNotEmpty: [ candidates detectMin: [ :each | each ] ]
]

{ #category : 'printing' }
REUnionTemporalExpression >> printOn: aStream [
	aStream nextPutAll: (String with: $().
	expressions
		do: [ :each | each printOn: aStream ]
		separatedBy: [ aStream nextPutAll: ' or ' ].
	aStream nextPutAll: (String with: $))
]
