Class {
	#name : 'RERangeEachYearExpression',
	#superclass : 'RECalendarTemporalExpression',
	#instVars : [
		'startMonth',
		'startDay',
		'endMonth',
		'endDay'
	],
	#category : 'RecurringEvents-Common',
	#package : 'RecurringEvents-Common'
}

{ #category : 'testing' }
RERangeEachYearExpression >> includes: aDateAndTime [
	| m d wrapsAcrossYear |
	m := aDateAndTime month.
	d := aDateAndTime dayOfMonth.
	wrapsAcrossYear := (startMonth > endMonth) or: [ startMonth = endMonth and: [ startDay > endDay ] ].
	wrapsAcrossYear
		ifFalse: [ ^ (self isMonth: m day: d atOrAfterMonth: startMonth day: startDay)
			and: [ self isMonth: m day: d atOrBeforeMonth: endMonth day: endDay ] ].
	^ (self isMonth: m day: d atOrAfterMonth: startMonth day: startDay)
		or: [ self isMonth: m day: d atOrBeforeMonth: endMonth day: endDay ]
]

{ #category : 'private' }
RERangeEachYearExpression >> isMonth: m day: d atOrAfterMonth: refMonth day: refDay [
	^ (m > refMonth) or: [ m = refMonth and: [ d >= refDay ] ]
]

{ #category : 'private' }
RERangeEachYearExpression >> isMonth: m day: d atOrBeforeMonth: refMonth day: refDay [
	^ (m < refMonth) or: [ m = refMonth and: [ d <= refDay ] ]
]

{ #category : 'printing' }
RERangeEachYearExpression >> printOn: aStream [
	aStream
		nextPutAll: ' from '.
	aStream print: startMonth; nextPutAll: '/'; print: startDay.
	aStream nextPutAll: ' to '.
	aStream print: endMonth; nextPutAll: '/'; print: endDay
]

{ #category : 'accessing' }
RERangeEachYearExpression >> startMonth: aStartMonth startDay: aStartDay endMonth: anEndMonth endDay: anEndDay [
	"Month numbers 1-12, day numbers 1-31. If the start is later in the year than the end
	(e.g. December 15 to January 15), the range wraps across the year boundary."
	startMonth := aStartMonth.
	startDay := aStartDay.
	endMonth := anEndMonth.
	endDay := anEndDay
]
