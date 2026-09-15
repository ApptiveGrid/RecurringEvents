Class {
	#name : 'REScheduler',
	#superclass : 'REGenericScheduler',
	#instVars : [
		'process',
		'processSemaphore',
		'schedule',
		'valueBlock',
		'lastAnnouncement'
	],
	#category : 'RecurringEvents-Engine',
	#package : 'RecurringEvents-Engine'
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

{ #category : 'running' }
REScheduler >> announce: aString [
	"once per change, not once per wait. The loop wakes at least every five seconds,
	so a line per turn is some seventeen thousand a day per scheduler, and nearly
	every one of them repeats what the line before it said. What is worth reading is
	the moment the answer changed - the first idle turn, and each new next
	occurrence, which carries its own time and so differs whenever it moves."
	lastAnnouncement = aString ifTrue: [ ^ self ].
	lastAnnouncement := aString.
	Transcript
		show: aString;
		cr
]

{ #category : 'as yet unclassified' }
REScheduler >> processNextOccurrence [
	| duration evaluationTime nextTime |
	schedule isEmpty ifTrue: [
			self announce: 'nothing scheduled, sleeping until something is'.
			"no timeout: with nothing scheduled there is nothing a timer could find, so
			the loop stops rather than waking every five seconds to say so again.
			#addItem: signals this semaphore, and a semaphore counts its signals - one
			arriving between the emptiness check and this wait is not lost"
			processSemaphore wait.
			^ self ].
	evaluationTime := DateAndTime now.
	schedule nextOccuringItemDo: [ :item :occurrence |
			occurrence <= evaluationTime
				ifTrue: [ self evaluateItem: item ]
				ifFalse: [
						duration := occurrence - evaluationTime.
						nextTime := occurrence ] ].
	duration ifNotNil: [
			self announce: 'next occurrence on ' , nextTime rounded asString.
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
