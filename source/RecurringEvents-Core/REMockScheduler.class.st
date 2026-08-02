Class {
	#name : 'REMockScheduler',
	#superclass : 'REGenericScheduler',
	#category : 'RecurringEvents-Core',
	#package : 'RecurringEvents-Core'
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
