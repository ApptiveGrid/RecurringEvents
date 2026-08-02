Class {
	#name : 'REMonthInYearExpression',
	#superclass : 'RECalendarTemporalExpression',
	#instVars : [
		'months'
	],
	#category : 'RecurringEvents-Common',
	#package : 'RecurringEvents-Common'
}

{ #category : 'testing' }
REMonthInYearExpression >> includes: aDateAndTime [
	^ months includes: aDateAndTime monthName
]

{ #category : 'accessing' }
REMonthInYearExpression >> months [
	^ months
]

{ #category : 'accessing' }
REMonthInYearExpression >> months: aCollection [
	"aCollection of month-name symbols, e.g. #(#June #July #August)."
	months := aCollection
]

{ #category : 'printing' }
REMonthInYearExpression >> printOn: aStream [
	aStream nextPutAll: ' in '.
	months
		do: [ :each | aStream nextPutAll: each ]
		separatedBy: [ aStream nextPutAll: ' , ' ]
]
