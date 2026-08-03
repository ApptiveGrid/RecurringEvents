Class {
	#name : 'REAbsoluteRangeExpression',
	#superclass : 'RETemporalExpression',
	#instVars : [
		'from',
		'to'
	],
	#category : 'RecurringEvents-Core',
	#package : 'RecurringEvents-Core'
}

{ #category : 'json' }
REAbsoluteRangeExpression class >> fromJsonDict: aDict [
	^ self new
		from: ((aDict includesKey: 'from') ifTrue: [ DateAndTime fromString: (aDict at: 'from') ])
		to: ((aDict includesKey: 'to') ifTrue: [ DateAndTime fromString: (aDict at: 'to') ])
]

{ #category : 'json' }
REAbsoluteRangeExpression >> asJsonDict [
	| dict |
	dict := Dictionary new.
	dict at: 'type' put: 'absoluteRange'.
	from ifNotNil: [ dict at: 'from' put: from asString ].
	to ifNotNil: [ dict at: 'to' put: to asString ].
	^ dict
]

{ #category : 'accessing' }
REAbsoluteRangeExpression >> from [
	^ from
]

{ #category : 'accessing' }
REAbsoluteRangeExpression >> from: aDateAndTimeOrNil to: anotherDateAndTimeOrNil [
	"An absolute (non-recurring) time window: includes every DateAndTime in [from, to).
	Either bound may be nil for an open end. Meant to be combined via Intersection with an
	actual recurring expression to clip it to a period - e.g. to change a series this-and-future:
	Union(Intersection(oldRule, RangeTo: boundary), Intersection(newRule, RangeFrom: boundary))."
	from := aDateAndTimeOrNil.
	to := anotherDateAndTimeOrNil
]

{ #category : 'testing' }
REAbsoluteRangeExpression >> includes: aDateAndTime [
	(from notNil and: [ aDateAndTime < from ]) ifTrue: [ ^ false ].
	(to notNil and: [ aDateAndTime >= to ]) ifTrue: [ ^ false ].
	^ true
]

{ #category : 'accessing' }
REAbsoluteRangeExpression >> nextOccurrenceAfter: aDateAndTime [
	"Earliest DateAndTime strictly after aDateAndTime for which #includes: holds, or nil if
	the window is already closed (aDateAndTime at or past a bounded to)."
	| candidate |
	aDateAndTime ifNil: [ ^ from ].
	(from notNil and: [ aDateAndTime < from ]) ifTrue: [ ^ from ].
	candidate := aDateAndTime + (Duration days: 1).
	^ (self includes: candidate) ifTrue: [ candidate ] ifFalse: [ nil ]
]

{ #category : 'printing' }
REAbsoluteRangeExpression >> printOn: aStream [
	aStream nextPutAll: 'from '.
	from ifNil: [ aStream nextPutAll: '-inf' ] ifNotNil: [ aStream print: from ].
	aStream nextPutAll: ' to '.
	to ifNil: [ aStream nextPutAll: '+inf' ] ifNotNil: [ aStream print: to ]
]

{ #category : 'accessing' }
REAbsoluteRangeExpression >> to [
	^ to
]
