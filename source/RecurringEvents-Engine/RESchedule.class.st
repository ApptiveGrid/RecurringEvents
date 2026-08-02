Class {
	#name : 'RESchedule',
	#superclass : 'Object',
	#instVars : [
		'itemsSemaphore',
		'activeItem'
	],
	#category : 'RecurringEvents-Engine',
	#package : 'RecurringEvents-Engine'
}

{ #category : 'adding' }
RESchedule >> addItem: item [
	Transcript show: 'adding element: ' , item asString; cr.
]

{ #category : 'initialization' }
RESchedule >> initialize [
	super initialize.
	itemsSemaphore := Semaphore forMutualExclusion.
]

{ #category : 'testing' }
RESchedule >> isEmpty [
	self subclassResponsibility
]

{ #category : 'enumerating' }
RESchedule >> nextOccuringItemDo: aBlock [
	| item occurrence |
	"schedule is empty. No need to proceed"
	item := self nextOccurringItem ifNil: [ ^ self ].

	"item is present but no further occurrences. This is a dangling dead
	item so we remove it"
	occurrence := item nextOccurrence.
	occurrence ifNil: [
		self removeItem: item.
		^ self ].
	[
		"remember the active item before we call aBlock"
		activeItem := item.
		aBlock value: item value: occurrence.

		"If the evaluated block removed the active item from the list of items
		we can determine if the activeItem instVar is set to nil.  If it still
		exists we remove it if there are no further occurrences "
		(activeItem notNil and: [ activeItem nextOccurrence isNil ])
			ifTrue: [ self removeItem: item ] ]
		ensure: [
			"Ensure the activeItem is nil not to introduce strange behaviour"
			activeItem := nil ].
]

{ #category : 'accessing' }
RESchedule >> nextOccurrence [
	self subclassResponsibility
]

{ #category : 'enumerating' }
RESchedule >> nextOccurringItem [
	self subclassResponsibility
]

{ #category : 'as yet unclassified' }
RESchedule >> on: dateAndTime evaluate: objectWithValue [
	self addItem: (REScheduleItem new
			temporalExpression: dateAndTime;
		event: objectWithValue)
]

{ #category : 'as yet unclassified' }
RESchedule >> on: dateAndTime sendMessage: selector to: object [
	self addItem: (REScheduleItem new
			temporalExpression: dateAndTime;
		event: (REEventMessageSend new
			object: object;
			selector: selector ))
]

{ #category : 'enumerating' }
RESchedule >> removeItem: item [
	Transcript show: 'removing item: ' , item asString; cr.
]

{ #category : 'accessing' }
RESchedule >> save: item [
	self subclassResponsibility
]

{ #category : 'accessing' }
RESchedule >> selectItemsWithEventType: aClass andCondition: aBlock [
	self subclassResponsibility
]
