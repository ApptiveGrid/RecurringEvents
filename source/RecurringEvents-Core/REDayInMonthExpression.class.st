Class {
	#name : 'REDayInMonthExpression',
	#superclass : 'RECalendarTemporalExpression',
	#instVars : [
		'day',
		'ordinal',
		'weekday'
	],
	#category : 'RecurringEvents-Core',
	#package : 'RecurringEvents-Core'
}

{ #category : 'accessing' }
REDayInMonthExpression >> day: anInteger [
	"Matches a fixed calendar day number of the month, e.g. 1 for the 1st.
	A negative number counts from the end of the month (-1 = last day)."
	day := anInteger
]

{ #category : 'testing' }
REDayInMonthExpression >> includes: aDateAndTime [
	^ day
		ifNotNil: [ self includesByDay: aDateAndTime ]
		ifNil: [ self includesByOrdinalWeekday: aDateAndTime ]
]

{ #category : 'private' }
REDayInMonthExpression >> includesByDay: aDateAndTime [
	| targetDay |
	targetDay := day > 0
		ifTrue: [ day ]
		ifFalse: [ aDateAndTime daysInMonth + day + 1 ].
	^ aDateAndTime dayOfMonth = targetDay
]

{ #category : 'private' }
REDayInMonthExpression >> includesByOrdinalWeekday: aDateAndTime [
	aDateAndTime dayOfWeekName = weekday ifFalse: [ ^ false ].
	^ ordinal > 0
		ifTrue: [ ((aDateAndTime dayOfMonth - 1) // 7) + 1 = ordinal ]
		ifFalse: [ ((aDateAndTime daysInMonth - aDateAndTime dayOfMonth) // 7) = (ordinal negated - 1) ]
]

{ #category : 'accessing' }
REDayInMonthExpression >> ordinal: anInteger weekday: aSymbol [
	"Matches the anInteger-th occurrence of aSymbol (e.g. #Thursday) in the month.
	A negative ordinal counts from the end of the month (-1 = last such weekday)."
	ordinal := anInteger.
	weekday := aSymbol
]

{ #category : 'printing' }
REDayInMonthExpression >> printOn: aStream [
	day
		ifNotNil: [
			aStream nextPutAll: ' day '.
			aStream print: day ]
		ifNil: [
			aStream nextPutAll: ' the '.
			aStream print: ordinal.
			aStream nextPutAll: ' ' , weekday ]
]
