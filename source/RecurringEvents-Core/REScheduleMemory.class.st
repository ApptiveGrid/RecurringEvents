Class {
	#name : 'REScheduleMemory',
	#superclass : 'RESchedule',
	#instVars : [
		'items'
	],
	#category : 'RecurringEvents-Core',
	#package : 'RecurringEvents-Core'
}

{ #category : 'adding' }
REScheduleMemory >> addItem: item [
	super addItem: item.
	itemsSemaphore critical: [
		items add: item ].
]

{ #category : 'initialization' }
REScheduleMemory >> initialize [
	super initialize.
	items := SortedCollection new sortBlock: [ :a :b | a occurrsBefore: b ].
]

{ #category : 'testing' }
REScheduleMemory >> isEmpty [
	^ itemsSemaphore critical: [
			items isEmpty ]
]

{ #category : 'as yet unclassified' }
REScheduleMemory >> itemHasBeenEvaluated: item [
	itemsSemaphore critical: [
		items reSort ]
]

{ #category : 'accessing' }
REScheduleMemory >> nextOccurrence [
	itemsSemaphore critical: [
		items ifEmpty: [ ^ nil ].
		^ items first nextOccurrence ]
]

{ #category : 'enumerating' }
REScheduleMemory >> nextOccurringItem [
	itemsSemaphore critical: [
		^ items first ]
]

{ #category : 'removing' }
REScheduleMemory >> removeItem: item [
	super removeItem: item.
	itemsSemaphore critical: [
		(item == activeItem)
			ifTrue: [ activeItem := nil ].
		items remove: item ]
]

{ #category : 'removing' }
REScheduleMemory >> removeItemsFor: anObject [
	| toRemove |
	self flag: #todo.
	"does only work for message send items"

	"find all schedule items that belong to anObject"
	toRemove := items
		select: [ :item | item event object = anObject ].

	"if the items for an object want to remove the active item we
	are processing right now then we notify this by setting the
	activeItem to nil"
	(toRemove includes: activeItem) ifTrue: [
		activeItem := nil ].

	items removeAll: toRemove 
]

{ #category : 'adding' }
REScheduleMemory >> save: item [
	"REScheduleMemory keeps reference on objects hence they are auomatically saved"
]

{ #category : 'as yet unclassified' }
REScheduleMemory >> selectItemsWithEventType: aClass andCondition: aBlock [
	^ items
		select: [ :item | item event class = aClass and: [ aBlock value: item event ] ].
]
