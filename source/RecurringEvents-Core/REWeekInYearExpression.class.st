Class {
	#name : 'REWeekInYearExpression',
	#superclass : 'RECalendarTemporalExpression',
	#instVars : [
		'weeks'
	],
	#category : 'RecurringEvents-Core',
	#package : 'RecurringEvents-Core'
}

{ #category : 'json' }
REWeekInYearExpression class >> fromJsonDict: aDict [
	^ self new weeks: (aDict at: 'weeks') asArray
]

{ #category : 'json' }
REWeekInYearExpression >> asJsonDict [
	^ Dictionary new
		at: 'type' put: 'weekInYear';
		at: 'weeks' put: weeks asArray;
		yourself
]

{ #category : 'testing' }
REWeekInYearExpression >> includes: aDateAndTime [
	| week total |
	week := self isoWeekNumberFor: aDateAndTime.
	total := self isoWeeksInYear: (self isoWeekYearFor: aDateAndTime).
	^ (weeks includes: week) or: [ weeks includes: week - total - 1 ]
]

{ #category : 'private' }
REWeekInYearExpression >> isoDayOfWeekFor: aDateAndTime [
	"Pharo dayOfWeek is Sunday=1..Saturday=7; ISO 8601 wants Monday=1..Sunday=7."
	^ ((aDateAndTime dayOfWeek + 5) \\ 7) + 1
]

{ #category : 'private' }
REWeekInYearExpression >> isoWeekNumberFor: aDateAndTime [
	| dayOfYear isoDow week |
	dayOfYear := aDateAndTime dayOfYear.
	isoDow := self isoDayOfWeekFor: aDateAndTime.
	week := (dayOfYear - isoDow + 10) // 7.
	week < 1 ifTrue: [ ^ self isoWeeksInYear: aDateAndTime year - 1 ].
	week > (self isoWeeksInYear: aDateAndTime year) ifTrue: [ ^ 1 ].
	^ week
]

{ #category : 'private' }
REWeekInYearExpression >> isoWeekYearFor: aDateAndTime [
	"The ISO week-year a date belongs to can differ from its calendar year for a few days
	around Dec 31/Jan 1 - e.g. Jan 1 can belong to ISO week 52/53 of the PREVIOUS year."
	| dayOfYear isoDow week |
	dayOfYear := aDateAndTime dayOfYear.
	isoDow := self isoDayOfWeekFor: aDateAndTime.
	week := (dayOfYear - isoDow + 10) // 7.
	week < 1 ifTrue: [ ^ aDateAndTime year - 1 ].
	week > (self isoWeeksInYear: aDateAndTime year) ifTrue: [ ^ aDateAndTime year + 1 ].
	^ aDateAndTime year
]

{ #category : 'private' }
REWeekInYearExpression >> isoWeeksInYear: aYear [
	"Dec 28 always falls in the last ISO week of aYear, so its own week number (via the plain
	dayOfYear-based formula, no rollover-handling needed since its never near a boundary) is
	the total number of ISO weeks in aYear (52 or 53)."
	| dec28 |
	dec28 := DateAndTime year: aYear month: 12 day: 28.
	^ (dec28 dayOfYear - (self isoDayOfWeekFor: dec28) + 10) // 7
]

{ #category : 'printing' }
REWeekInYearExpression >> printOn: aStream [
	aStream nextPutAll: ' ISO week '.
	weeks printOn: aStream
]

{ #category : 'accessing' }
REWeekInYearExpression >> weeks [
	^ weeks
]

{ #category : 'accessing' }
REWeekInYearExpression >> weeks: aCollection [
	"RFC 5545 BYWEEKNO. aCollection of Integers, 1-53 (ISO 8601 week number); negative counts
	from the end of the ISO week-year (-1 = the last ISO week of that year, which is 52 or 53
	depending on the year). Uses plain ISO 8601 week numbering (weeks start Monday, week 1 is
	the one containing the years first Thursday) - independent of REIntervalExpressions wkst,
	since none of the three major calendar tools implement BYWEEKNO at all (see decisions doc),
	so theres no real interop pressure to also parameterize this by WKST."
	weeks := aCollection
]
