Class {
	#name : 'REScheduler',
	#superclass : 'REGenericScheduler',
	#instVars : [
		'process',
		'processSemaphore',
		'schedule',
		'valueBlock'
	],
	#category : 'RecurringEvents-Core',
	#package : 'RecurringEvents-Core'
}

{ #category : 'adding' }
REScheduler >> addItem: element [
	schedule addItem: element.
	processSemaphore signal
]

{ #category : 'as yet unclassified' }
REScheduler >> defaultValueBlock [
	^ [ :item |
		Transcript show: 'evaluating item: ' , item asString; cr.
		item value ]
]

{ #category : 'as yet unclassified' }
REScheduler >> evaluateItem: item [
	"An error executing the item's action must not remove it from the schedule -
	that would permanently kill all future occurrences of a recurring item over a single
	failed run. Whether the item still has future occurrences is already decided
	independently by RESchedule>>nextOccuringItemDo: after this call returns."
	[
		self valueBlock value: item.
		schedule itemHasBeenEvaluated: item ]
		on: Error
		do: [ :error |
			Transcript show: 'scheduler error: ' , error asString; cr.
			Smalltalk
				at: #SnapDump
				ifPresent: [ :cls |
					cls handleException: error ] ]
]

{ #category : 'initialization' }
REScheduler >> initialize [
	super initialize.
	processSemaphore := Semaphore new.
]

{ #category : 'accessing' }
REScheduler >> maxWaitTime [
	^ Duration seconds: 5
]

{ #category : 'accessing' }
REScheduler >> nextOccurrence [
	^ schedule nextOccurrence 
]

{ #category : 'as yet unclassified' }
REScheduler >> processNextOccurrence [
	| duration evaluationTime nextTime |
	schedule isEmpty ifTrue: [
			Transcript
				show: 'repository is empty. waiting....';
				cr.
			processSemaphore waitTimeoutMSecs: self maxWaitTime asMilliSeconds.
			^ self ].
	evaluationTime := DateAndTime now.
	schedule nextOccuringItemDo: [ :item :occurrence |
			occurrence <= evaluationTime
				ifTrue: [ self evaluateItem: item ]
				ifFalse: [
						duration := occurrence - evaluationTime.
						nextTime := occurrence ] ].
	duration ifNotNil: [
			Transcript
				show:
					'next occurrence on ' , nextTime rounded asString , ' waiting '
					, duration asString;
				cr.
			processSemaphore waitTimeoutMilliseconds:
				(duration asMilliSeconds min: self maxWaitTime asMilliSeconds) ]
]

{ #category : 'as yet unclassified' }
REScheduler >> removeItemsFor: anObject [
	schedule removeItemsFor: anObject
]

{ #category : 'accessing' }
REScheduler >> schedule: aSchedule [
	schedule := aSchedule
]

{ #category : 'accessing' }
REScheduler >> start [
	process ifNotNil: [ ^ self ].

	process := [
		[ [ self processNextOccurrence ]
			on: Error
			do: [ :err | err pass ] ] repeat ] forkNamed: 'Scheduler process'
]

{ #category : 'accessing' }
REScheduler >> stop [
	process ifNil: [ ^ self ].

	process terminate.
	process := nil
]

{ #category : 'accessing' }
REScheduler >> valueBlock [
	^ valueBlock ifNil: [
		valueBlock := self defaultValueBlock ]
]

{ #category : 'accessing' }
REScheduler >> valueBlock: aBlock [
	valueBlock := aBlock
]
