Class {
	#name : 'REDurationISO8601Test',
	#superclass : 'TestCase',
	#category : 'RecurringEvents-Tests',
	#package : 'RecurringEvents-Tests'
}

{ #category : 'tests' }
REDurationISO8601Test >> testDaysOnly [
	self assert: (Duration days: 7) asISO8601Duration equals: 'P7D'.
	self assert: (Duration fromISO8601Duration: 'P7D') equals: (Duration days: 7)
]

{ #category : 'tests' }
REDurationISO8601Test >> testMixedDaysAndTime [
	| d |
	d := Duration days: 1 hours: 2 minutes: 3 seconds: 4.
	self assert: d asISO8601Duration equals: 'P1DT2H3M4S'.
	self assert: (Duration fromISO8601Duration: 'P1DT2H3M4S') equals: d
]

{ #category : 'tests' }
REDurationISO8601Test >> testTimeOnly [
	self assert: (Duration seconds: 90) asISO8601Duration equals: 'PT1M30S'.
	self assert: (Duration fromISO8601Duration: 'PT1M30S') equals: (Duration seconds: 90)
]

{ #category : 'tests' }
REDurationISO8601Test >> testZeroDuration [
	self assert: (Duration seconds: 0) asISO8601Duration equals: 'P0D'.
	self assert: (Duration fromISO8601Duration: 'P0D') equals: (Duration seconds: 0)
]
