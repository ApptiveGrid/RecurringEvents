Class {
	#name : 'REIntervalExpression',
	#superclass : 'RETemporalExpression',
	#instVars : [
		'start',
		'unit',
		'interval'
	],
	#category : 'RecurringEvents-Core',
	#package : 'RecurringEvents-Core'
}

{ #category : 'json' }
REIntervalExpression class >> fromJsonDict: aDict [
	^ self new
		start: (DateAndTime fromString: (aDict at: 'start'))
		unit: (aDict at: 'unit') asSymbol
		interval: (aDict at: 'interval')
]

{ #category : 'json' }
REIntervalExpression >> asJsonDict [
	^ Dictionary new
		at: 'type' put: 'interval';
		at: 'start' put: start asString;
		at: 'unit' put: unit asString;
		at: 'interval' put: interval;
		yourself
]

{ #category : 'private' }
REIntervalExpression >> elapsedPeriodsFor: aDateAndTime [
	"Number of complete units of #unit between start and aDateAndTime (>= 0, since callers
	only invoke this for aDateAndTime >= start)."
	unit = #week ifTrue: [ ^ (aDateAndTime asDate - start asDate) days // 7 ].
	unit = #month ifTrue: [ ^ ((aDateAndTime year - start year) * 12) + (aDateAndTime month - start month) ].
	unit = #year ifTrue: [ ^ aDateAndTime year - start year ].
	self error: 'Unknown interval unit: ' , unit
]

{ #category : 'testing' }
REIntervalExpression >> includes: aDateAndTime [
	aDateAndTime < start ifTrue: [ ^ false ].
	^ (self elapsedPeriodsFor: aDateAndTime) \\ interval = 0
]

{ #category : 'accessing' }
REIntervalExpression >> interval [
	^ interval
]

{ #category : 'private' }
REIntervalExpression >> nextMatchingElapsedAtOrAfter: n [
	"Smallest multiple of interval that is >= n. Only ever called with an n that is NOT
	itself a multiple (see #nextOccurrenceAfter:), so the result is always > n too."
	^ (n + interval - 1) // interval * interval
]

{ #category : 'accessing' }
REIntervalExpression >> nextOccurrenceAfter: aDateAndTime [
	"Earliest DateAndTime strictly after aDateAndTime for which #includes: holds.
	Computed analytically (not a brute-force day scan) so that intervals spanning
	more than a year (e.g. every 2 years) still resolve in O(1)."
	| candidate |
	aDateAndTime ifNil: [ ^ start ].
	aDateAndTime < start ifTrue: [ ^ start ].
	candidate := aDateAndTime + (Duration days: 1).
	^ (self includes: candidate)
		ifTrue: [ candidate ]
		ifFalse: [ self startOfPeriod: (self nextMatchingElapsedAtOrAfter: (self elapsedPeriodsFor: candidate)) ]
]

{ #category : 'printing' }
REIntervalExpression >> printOn: aStream [
	aStream
		nextPutAll: ' every ';
		print: interval;
		nextPutAll: ' ';
		nextPutAll: unit asString.
	interval = 1 ifFalse: [ aStream nextPutAll: 's' ]
]

{ #category : 'accessing' }
REIntervalExpression >> start [
	^ start
]

{ #category : 'accessing' }
REIntervalExpression >> start: aDateAndTime unit: aSymbol interval: anInteger [
	"aSymbol is one of #week/#month/#year. anInteger (>= 1) is the RFC 5545 INTERVAL:
	every anInteger-th aSymbol, counted from aDateAndTime."
	start := aDateAndTime.
	unit := aSymbol.
	interval := anInteger
]

{ #category : 'private' }
REIntervalExpression >> startOfPeriod: elapsed [
	"The first DateAndTime (at midnight) of the #unit-period that is elapsed units after start's own period."
	| totalMonths |
	unit = #week ifTrue: [ ^ start + (Duration days: elapsed * 7) ].
	unit = #month ifTrue: [
		totalMonths := (start month - 1) + elapsed.
		^ DateAndTime year: start year + (totalMonths // 12) month: (totalMonths \\ 12) + 1 day: 1 ].
	unit = #year ifTrue: [ ^ DateAndTime year: start year + elapsed month: 1 day: 1 ].
	self error: 'Unknown interval unit: ' , unit
]

{ #category : 'accessing' }
REIntervalExpression >> unit [
	^ unit
]
