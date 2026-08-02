Class {
	#name : 'REMonthInYearExpression',
	#superclass : 'RECalendarTemporalExpression',
	#instVars : [
		'months'
	],
	#category : 'RecurringEvents-Core',
	#package : 'RecurringEvents-Core'
}

{ #category : 'json' }
REMonthInYearExpression class >> fromJsonDict: aDict [
	^ self new months: ((aDict at: 'months') collect: [ :each | self symbolForJsonName: each ])
]

{ #category : 'json' }
REMonthInYearExpression >> asJsonDict [
	^ Dictionary new
		at: 'type' put: 'monthInYear';
		at: 'months' put: (months collect: [ :each | self class jsonNameFor: each ]) asArray;
		yourself
]

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
