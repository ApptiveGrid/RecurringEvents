Class {
	#name : 'REOccurrenceRegistrationTest',
	#superclass : 'TestCase',
	#category : 'RecurringEvents-Tests',
	#package : 'RecurringEvents-Tests'
}

{ #category : 'tests' }
REOccurrenceRegistrationTest >> testEmptyScheduleHasNoRegistration [
	| schedule |
	schedule := REScheduleMemory new origin: 'db-99'.
	self assert: schedule asOccurrenceRegistration isNil
]

{ #category : 'tests' }
REOccurrenceRegistrationTest >> testScheduleProducesRegistrationForItsEarliestOccurrence [
	| schedule dur item |
	schedule := REScheduleMemory new origin: 'db-42'.
	dur := REDurationExpression new duration: (Duration days: 7).
	dur instVarNamed: #start put: (DateAndTime year: 2026 month: 1 day: 1).
	item := REScheduleItem new.
	item instVarNamed: #temporalExpression put: dur.
	item event: [ nil ].
	schedule addItem: item.
	self assert: schedule asOccurrenceRegistration origin equals: 'db-42'.
	self assert: schedule asOccurrenceRegistration nextOccurrence equals: (DateAndTime year: 2026 month: 1 day: 1)
]

{ #category : 'tests' }
REOccurrenceRegistrationTest >> testStonRoundTrip [
	| reg stonStr backAgain |
	reg := REOccurrenceRegistration origin: 'db-42' nextOccurrence: (DateAndTime year: 2026 month: 1 day: 1).
	stonStr := reg asStonString.
	backAgain := REOccurrenceRegistration fromStonString: stonStr.
	self assert: backAgain origin equals: reg origin.
	self assert: backAgain nextOccurrence equals: reg nextOccurrence
]
