Extension { #name : 'DateAndTime' }

{ #category : '*recurringevents-common' }
DateAndTime >> asTemporalExpression [
	^ REDateAndTimeExpression new
		dateAndTime: self
]
