Class {
	#name : 'RESchedulerTest',
	#superclass : 'TestCase',
	#category : 'RecurringEvents-Tests',
	#package : 'RecurringEvents-Tests'
}

{ #category : 'tests' }
RESchedulerTest >> testEvaluateItemErrorDoesNotRemoveRecurringItem [
	"Regression test: a failed run of a recurring item must not delete its future occurrences."
	| schedule item scheduler dur |
	schedule := REScheduleMemory new.
	dur := REDurationExpression new duration: (Duration seconds: 1).
	dur instVarNamed: #start put: (DateAndTime now - (Duration seconds: 5)).
	item := REScheduleItem new.
	item instVarNamed: #temporalExpression put: dur.
	item event: [ Error signal: 'boom' ].
	schedule addItem: item.
	scheduler := REScheduler new schedule: schedule.
	schedule nextOccuringItemDo: [ :it :occ | scheduler evaluateItem: it ].
	self deny: schedule isEmpty.
	self assert: item hasNextOccurrence
]

{ #category : 'tests' }
RESchedulerTest >> testEvaluateItemErrorStillRemovesExhaustedItem [
	"A single-occurrence item that has already fired must still be cleaned up even when its
	action raises an error - only the recurring case in the test above should survive."
	| schedule item scheduler fixedDate |
	schedule := REScheduleMemory new.
	fixedDate := REDateAndTimeExpression new dateAndTime: (DateAndTime now - (Duration seconds: 5)).
	item := REScheduleItem new.
	item instVarNamed: #temporalExpression put: fixedDate.
	item event: [ Error signal: 'boom' ].
	schedule addItem: item.
	scheduler := REScheduler new schedule: schedule.
	schedule nextOccuringItemDo: [ :it :occ | scheduler evaluateItem: it ].
	self assert: schedule isEmpty
]

{ #category : 'tests' }
RESchedulerTest >> testProcessNextOccurrenceDoesNotEvaluateFutureItem [
	| schedule item scheduler executed dateAndTimeExpr |
	executed := false.
	schedule := REScheduleMemory new.
	dateAndTimeExpr := REDateAndTimeExpression new dateAndTime: (DateAndTime now + (Duration days: 1)).
	item := REScheduleItem new.
	item instVarNamed: #temporalExpression put: dateAndTimeExpr.
	item event: [ executed := true ].
	schedule addItem: item.
	scheduler := REScheduler new schedule: schedule.
	scheduler processNextOccurrence.
	self deny: executed
]

{ #category : 'tests' }
RESchedulerTest >> testProcessNextOccurrenceEvaluatesDueItem [
	| schedule item scheduler executed dur |
	executed := false.
	schedule := REScheduleMemory new.
	dur := REDurationExpression new duration: (Duration seconds: 1).
	dur instVarNamed: #start put: (DateAndTime now - (Duration seconds: 5)).
	item := REScheduleItem new.
	item instVarNamed: #temporalExpression put: dur.
	item event: [ executed := true ].
	schedule addItem: item.
	scheduler := REScheduler new schedule: schedule.
	scheduler processNextOccurrence.
	self assert: executed
]
