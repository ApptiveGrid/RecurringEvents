Class {
	#name : 'REDayInWeekExpression',
	#superclass : 'RECalendarTemporalExpression',
	#instVars : [
		'weekdays'
	],
	#category : 'RecurringEvents-Core',
	#package : 'RecurringEvents-Core'
}

{ #category : 'json' }
REDayInWeekExpression class >> fromJsonDict: aDict [
	^ self new weekdays: ((aDict at: 'weekdays') collect: [ :each | self symbolForJsonName: each ])
]

{ #category : 'json' }
REDayInWeekExpression >> asJsonDict [
	^ Dictionary new
		at: 'type' put: 'dayInWeek';
		at: 'weekdays' put: (weekdays collect: [ :each | self class jsonNameFor: each ]) asArray;
		yourself
]

{ #category : 'testing' }
REDayInWeekExpression >> includes: aDateAndTime [
	^ weekdays includes: aDateAndTime dayOfWeekName
]

{ #category : 'printing' }
REDayInWeekExpression >> printOn: aStream [
	aStream nextPutAll: ' on '.
	weekdays
		do: [ :each | aStream nextPutAll: each ]
		separatedBy: [ aStream nextPutAll: ' , ' ]
]

{ #category : 'accessing' }
REDayInWeekExpression >> weekdays [
	^ weekdays
]

{ #category : 'accessing' }
REDayInWeekExpression >> weekdays: aCollection [
	"aCollection of weekday-name symbols, e.g. #(#Monday #Wednesday)."
	weekdays := aCollection
]
