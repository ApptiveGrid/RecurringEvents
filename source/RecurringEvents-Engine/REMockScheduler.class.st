Class {
	#name : 'REMockScheduler',
	#superclass : 'REGenericScheduler',
	#category : 'RecurringEvents-Engine',
	#package : 'RecurringEvents-Engine'
}

{ #category : 'adding' }
REMockScheduler >> addItem: aScheduleItem [
	[
		(Delay forSeconds: 0.5) wait.
		aScheduleItem value ] fork
]

{ #category : 'removing' }
REMockScheduler >> removeItemsFor: anObject [
]
