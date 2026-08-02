Class {
	#name : 'REEventMessageSend',
	#superclass : 'Object',
	#instVars : [
		'object',
		'selector'
	],
	#category : 'RecurringEvents-Core',
	#package : 'RecurringEvents-Core'
}

{ #category : 'as yet unclassified' }
REEventMessageSend >> object [
	^ object
]

{ #category : 'accessing' }
REEventMessageSend >> object: anObject [
	object := anObject
]

{ #category : 'accessing' }
REEventMessageSend >> selector: anObject [
	selector := anObject
]

{ #category : 'evaluating' }
REEventMessageSend >> value [
	object perform: selector asSymbol
]
