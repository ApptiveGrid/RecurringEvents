Class {
	#name : 'REDayInYearExpression',
	#superclass : 'RECalendarTemporalExpression',
	#instVars : [
		'days'
	],
	#category : 'RecurringEvents-Core',
	#package : 'RecurringEvents-Core'
}

{ #category : 'json' }
REDayInYearExpression class >> fromJsonDict: aDict [
	^ self new days: (aDict at: 'days') asArray
]

{ #category : 'json' }
REDayInYearExpression >> asJsonDict [
	^ Dictionary new
		at: 'type' put: 'dayInYear';
		at: 'days' put: days asArray;
		yourself
]

{ #category : 'accessing' }
REDayInYearExpression >> days [
	^ days
]

{ #category : 'accessing' }
REDayInYearExpression >> days: aCollection [
	"RFC 5545 BYYEARDAY. aCollection of Integers, 1-366; negative counts from the end of the
	year (-1 = the last day of the year, i.e. Dec 31 or Dec 30 on years with only 365 days)."
	days := aCollection
]

{ #category : 'testing' }
REDayInYearExpression >> includes: aDateAndTime [
	| dayOfYear total |
	dayOfYear := aDateAndTime dayOfYear.
	total := aDateAndTime daysInYear.
	^ (days includes: dayOfYear) or: [ days includes: dayOfYear - total - 1 ]
]

{ #category : 'printing' }
REDayInYearExpression >> printOn: aStream [
	aStream nextPutAll: ' day-of-year '.
	days printOn: aStream
]
