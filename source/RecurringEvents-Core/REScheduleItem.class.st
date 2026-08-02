Class {
	#name : 'REScheduleItem',
	#superclass : 'Object',
	#instVars : [
		'id',
		'event',
		'temporalExpression',
		'lastEvaluated'
	],
	#category : 'RecurringEvents-Core',
	#package : 'RecurringEvents-Core'
}

{ #category : 'accessing' }
REScheduleItem >> event [
	^ event
]

{ #category : 'evaluating' }
REScheduleItem >> event: anObject [
	event := anObject
]

{ #category : 'testing' }
REScheduleItem >> hasNextOccurrence [
	^ self nextOccurrence notNil
]

{ #category : 'accessing' }
REScheduleItem >> id [
	^ id
]

{ #category : 'accessing' }
REScheduleItem >> id: anObject [
	id := anObject
]

{ #category : 'as yet unclassified' }
REScheduleItem >> lastEvaluated [
	^ lastEvaluated
]

{ #category : 'accessing' }
REScheduleItem >> nextOccurrence [
	"answers nil if there is no next occurence"
	Transcript show: 'temporalExpression is: ' , temporalExpression asString; cr.
	Transcript show: 'lastEvaluated is: ' , lastEvaluated asString; cr.
	^ temporalExpression nextOccurrenceAfter: lastEvaluated
]

{ #category : 'testing' }
REScheduleItem >> occurrsBefore: item [
	| thisOccurrence otherOccurence |
	thisOccurrence := self nextOccurrence.
	otherOccurence := item nextOccurrence.
	(thisOccurrence isNil | otherOccurence isNil) ifTrue: [
		^ false ].
	^ thisOccurrence < otherOccurence
]

{ #category : 'printing' }
REScheduleItem >> printOn: aStream [
	aStream
		nextPutAll: 'schedule item id: ';
		nextPutAll: id asString;
		nextPutAll: ', '.
	temporalExpression printOn: aStream
]

{ #category : 'accessing' }
REScheduleItem >> temporalExpression [
	^ temporalExpression
]

{ #category : 'accessing' }
REScheduleItem >> temporalExpression: anObject [
	temporalExpression := anObject asTemporalExpression.
]

{ #category : 'evaluating' }
REScheduleItem >> value [
	lastEvaluated := DateAndTime now.
	event value
]
