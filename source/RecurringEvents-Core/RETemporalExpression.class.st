Class {
	#name : 'RETemporalExpression',
	#superclass : 'Object',
	#category : 'RecurringEvents-Core',
	#package : 'RecurringEvents-Core'
}

{ #category : 'json' }
RETemporalExpression class >> fromJsonDict: aDict [
	| type |
	type := aDict at: 'type'.
	type = 'dateAndTime' ifTrue: [ ^ REDateAndTimeExpression fromJsonDict: aDict ].
	type = 'duration' ifTrue: [ ^ REDurationExpression fromJsonDict: aDict ].
	type = 'dayInWeek' ifTrue: [ ^ REDayInWeekExpression fromJsonDict: aDict ].
	type = 'monthInYear' ifTrue: [ ^ REMonthInYearExpression fromJsonDict: aDict ].
	type = 'dayInMonth' ifTrue: [ ^ REDayInMonthExpression fromJsonDict: aDict ].
	type = 'rangeEachYear' ifTrue: [ ^ RERangeEachYearExpression fromJsonDict: aDict ].
	type = 'union' ifTrue: [ ^ REUnionTemporalExpression fromJsonDict: aDict ].
	type = 'intersection' ifTrue: [ ^ REIntersectionTemporalExpression fromJsonDict: aDict ].
	type = 'difference' ifTrue: [ ^ REDifferenceTemporalExpression fromJsonDict: aDict ].
	self error: 'Unknown RecurringEvents JSON type: ' , type
]

{ #category : 'json' }
RETemporalExpression class >> fromJsonString: aString [
	^ self fromJsonDict: (NeoJSONReader fromString: aString)
]

{ #category : 'json' }
RETemporalExpression class >> jsonNameFor: aSymbol [
	^ aSymbol asString asLowercase
]

{ #category : 'json' }
RETemporalExpression class >> symbolForJsonName: aString [
	^ (aString first asUppercase asString , aString allButFirst) asSymbol
]

{ #category : 'json' }
RETemporalExpression >> asJsonDict [
	^ self subclassResponsibility
]

{ #category : 'json' }
RETemporalExpression >> asJsonString [
	^ NeoJSONWriter toString: self asJsonDict
]

{ #category : 'testing' }
RETemporalExpression >> includes: aDateAndTime [
	^ self subclassResponsibility
]

{ #category : 'accessing' }
RETemporalExpression >> nextOccurrence [
	^ self nextOccurrenceAfter: nil
]

{ #category : 'as yet unclassified' }
RETemporalExpression >> nextOccurrenceAfter: aDateAndTime [
	self subclassResponsibility
]
