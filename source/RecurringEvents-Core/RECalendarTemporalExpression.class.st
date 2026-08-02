Class {
	#name : 'RECalendarTemporalExpression',
	#superclass : 'RETemporalExpression',
	#category : 'RecurringEvents-Core',
	#package : 'RecurringEvents-Core'
}

{ #category : 'as yet unclassified' }
RECalendarTemporalExpression >> nextOccurrenceAfter: aDateAndTime [
	| base candidate limit |
	base := aDateAndTime ifNil: [ DateAndTime now ].
	candidate := base + (Duration days: 1).
	limit := base + self searchWindow.
	[ candidate <= limit ] whileTrue: [
		(self includes: candidate) ifTrue: [ ^ candidate ].
		candidate := candidate + (Duration days: 1) ].
	^ nil
]

{ #category : 'private' }
RECalendarTemporalExpression >> searchWindow [
	"Upper bound for the brute-force search in #nextOccurrenceAfter: below.
	Every concrete calendar expression recurs at most yearly, so just over a year is always enough."
	^ Duration days: 370
]
