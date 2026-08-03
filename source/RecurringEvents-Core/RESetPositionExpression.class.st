Class {
	#name : 'RESetPositionExpression',
	#superclass : 'RECalendarTemporalExpression',
	#instVars : [
		'candidate',
		'period',
		'positions'
	],
	#category : 'RecurringEvents-Core',
	#package : 'RecurringEvents-Core'
}

{ #category : 'json' }
RESetPositionExpression class >> fromJsonDict: aDict [
	^ self new
		candidate: (RETemporalExpression fromJsonDict: (aDict at: 'candidate'))
		period: (aDict at: 'period') asSymbol
		positions: (aDict at: 'positions') asArray
]

{ #category : 'json' }
RESetPositionExpression >> asJsonDict [
	^ Dictionary new
		at: 'type' put: 'setPosition';
		at: 'candidate' put: candidate asJsonDict;
		at: 'period' put: period asString;
		at: 'positions' put: positions asArray;
		yourself
]

{ #category : 'accessing' }
RESetPositionExpression >> candidate [
	^ candidate
]

{ #category : 'accessing' }
RESetPositionExpression >> candidate: aTemporalExpression period: aSymbol positions: aCollection [
	"RFC 5545 BYSETPOS, generalized: within each calendar aSymbol-period (#month or #year)
	containing a date, enumerate the dates where aTemporalExpression includes: them (ascending);
	includes an aDateAndTime iff its 1-based position in that list (or its negative,
	from-the-end position, e.g. -1 = last) is in aCollection. More general than the
	fixed ordinal+weekday mode built into REDayInMonthExpression - e.g. positions
	#(2 -1) means the 2nd AND the last matching date in the period."
	candidate := aTemporalExpression.
	period := aSymbol.
	positions := aCollection
]

{ #category : 'private' }
RESetPositionExpression >> candidateDaysFrom: periodStart to: periodEnd [
	"Ascending list of Dates within [periodStart, periodEnd) where candidate includes: them."
	| result day |
	result := OrderedCollection new.
	day := periodStart.
	[ day < periodEnd ] whileTrue: [
		(candidate includes: day) ifTrue: [ result add: day asDate ].
		day := day + (Duration days: 1) ].
	^ result
]

{ #category : 'testing' }
RESetPositionExpression >> includes: aDateAndTime [
	| periodStart periodEnd candidates ascendingIndex descendingIndex |
	periodStart := self periodStartFor: aDateAndTime.
	periodEnd := self periodEndFor: aDateAndTime.
	candidates := self candidateDaysFrom: periodStart to: periodEnd.
	ascendingIndex := candidates indexOf: aDateAndTime asDate.
	ascendingIndex = 0 ifTrue: [ ^ false ].
	descendingIndex := ascendingIndex - candidates size - 1.
	^ (positions includes: ascendingIndex) or: [ positions includes: descendingIndex ]
]

{ #category : 'accessing' }
RESetPositionExpression >> period [
	^ period
]

{ #category : 'private' }
RESetPositionExpression >> periodEndFor: aDateAndTime [
	period = #month ifTrue: [ ^ (self periodStartFor: aDateAndTime) + (Duration days: aDateAndTime daysInMonth) ].
	period = #year ifTrue: [ ^ DateAndTime year: aDateAndTime year + 1 month: 1 day: 1 ].
	self error: 'Unknown setPosition period: ' , period
]

{ #category : 'private' }
RESetPositionExpression >> periodStartFor: aDateAndTime [
	period = #month ifTrue: [ ^ DateAndTime year: aDateAndTime year month: aDateAndTime month day: 1 ].
	period = #year ifTrue: [ ^ DateAndTime year: aDateAndTime year month: 1 day: 1 ].
	self error: 'Unknown setPosition period: ' , period
]

{ #category : 'accessing' }
RESetPositionExpression >> positions [
	^ positions
]

{ #category : 'printing' }
RESetPositionExpression >> printOn: aStream [
	aStream nextPutAll: 'positions ' .
	positions printOn: aStream.
	aStream nextPutAll: ' of (' .
	candidate printOn: aStream.
	aStream nextPutAll: ') per ' , period asString
]
