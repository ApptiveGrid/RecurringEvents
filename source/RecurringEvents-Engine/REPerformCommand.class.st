Class {
	#name : 'REPerformCommand',
	#superclass : 'Object',
	#instVars : [
		'selector'
	],
	#classInstVars : [
		'delegate'
	],
	#category : 'RecurringEvents-Engine',
	#package : 'RecurringEvents-Engine'
}

{ #category : 'accessing' }
REPerformCommand class >> delegate [
	^ delegate
]

{ #category : 'accessing' }
REPerformCommand class >> delegate: anObject [
	delegate := anObject
]

{ #category : 'undo-undo' }
REPerformCommand >> delegate [
	^ self class delegate
]

{ #category : 'accessing' }
REPerformCommand >> selector: anObject [
	selector := anObject
]

{ #category : 'undo-undo' }
REPerformCommand >> value [
	self delegate perform: selector asSymbol
]
