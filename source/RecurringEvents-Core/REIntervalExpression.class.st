Class {
	#name : 'REIntervalExpression',
	#superclass : 'RETemporalExpression',
	#instVars : [
		'start',
		'unit',
		'interval',
		'wkst'
	],
	#category : 'RecurringEvents-Core',
	#package : 'RecurringEvents-Core'
}

{ #category : 'json' }
REIntervalExpression class >> fromJsonDict: aDict [
	| expr |
	expr := self new
		start: (DateAndTime fromString: (aDict at: 'start'))
		unit: (aDict at: 'unit') asSymbol
		interval: (aDict at: 'interval').
	(aDict includesKey: 'wkst')
		ifTrue: [ expr wkst: (self symbolForJsonName: (aDict at: 'wkst')) ].
	^ expr
]

{ #category : 'json' }
REIntervalExpression >> asJsonDict [
	^ Dictionary new
		at: 'type' put: 'interval';
		at: 'start' put: start asString;
		at: 'unit' put: unit asString;
		at: 'interval' put: interval;
		at: 'wkst' put: (self class jsonNameFor: wkst);
		yourself
]

{ #category : 'private' }
REIntervalExpression >> elapsedPeriodsFor: aDateAndTime [
	"Number of complete units of #unit between start and aDateAndTime (>= 0, since callers
	only invoke this for aDateAndTime >= start). For #week, counts WKST-aligned calendar
	weeks (not raw 7-day blocks anchored to starts own weekday) - see #wkst:."
	unit = #week ifTrue: [ ^ ((self startOfWeekContaining: aDateAndTime) asDate - (self startOfWeekContaining: start) asDate) days // 7 ].
	unit = #month ifTrue: [ ^ ((aDateAndTime year - start year) * 12) + (aDateAndTime month - start month) ].
	unit = #year ifTrue: [ ^ aDateAndTime year - start year ].
	self error: 'Unknown interval unit: ' , unit
]

{ #category : 'testing' }
REIntervalExpression >> includes: aDateAndTime [
	aDateAndTime < start ifTrue: [ ^ false ].
	^ (self elapsedPeriodsFor: aDateAndTime) \\ interval = 0
]

{ #category : 'initialize' }
REIntervalExpression >> initialize [
	super initialize.
	wkst := #Monday
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
	"The first DateAndTime of the #unit-period that is elapsed units after starts own period.
	For #week this is a WKST-aligned calendar-week start (midnight), not necessarily midnight
	of the same weekday as start itself."
	| totalMonths |
	unit = #week ifTrue: [ ^ (self startOfWeekContaining: start) + (Duration days: elapsed * 7) ].
	unit = #month ifTrue: [
		totalMonths := (start month - 1) + elapsed.
		^ DateAndTime year: start year + (totalMonths // 12) month: (totalMonths \\ 12) + 1 day: 1 ].
	unit = #year ifTrue: [ ^ DateAndTime year: start year + elapsed month: 1 day: 1 ].
	self error: 'Unknown interval unit: ' , unit
]

{ #category : 'private' }
REIntervalExpression >> startOfWeekContaining: aDateAndTime [
	"The most recent wkst weekday on or before aDateAndTime (at midnight)."
	| wkstIndex offset |
	wkstIndex := #(#Sunday #Monday #Tuesday #Wednesday #Thursday #Friday #Saturday) indexOf: wkst.
	offset := (aDateAndTime dayOfWeek - wkstIndex) \\ 7.
	^ aDateAndTime - (Duration days: offset)
]

{ #category : 'accessing' }
REIntervalExpression >> unit [
	^ unit
]

{ #category : 'accessing' }
REIntervalExpression >> wkst [
	^ wkst
]

{ #category : 'accessing' }
REIntervalExpression >> wkst: aWeekdaySymbol [
	"RFC 5545 WKST: which weekday starts a calendar week, for #week-unit period counting.
	Only matters once BYDAY spans multiple weekdays whose calendar-week membership could
	otherwise be ambiguous (e.g. every 2 weeks on Tuesday and Sunday - whether that Sunday
	belongs to the same week as the preceding Tuesday depends on WKST). Defaults to #Monday,
	same as RFC 5545."
	wkst := aWeekdaySymbol
]
