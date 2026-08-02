Class {
	#name : 'REDayInWeekExpression',
	#superclass : 'RECalendarTemporalExpression',
	#instVars : [
		'weekdays'
	],
	#category : 'RecurringEvents-Core',
	#package : 'RecurringEvents-Core'
}

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
