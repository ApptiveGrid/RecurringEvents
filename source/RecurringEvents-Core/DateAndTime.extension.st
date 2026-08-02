Extension { #name : 'DateAndTime' }

{ #category : '*recurringevents-core' }
DateAndTime >> asTemporalExpression [
	^ REDateAndTimeExpression new
		dateAndTime: self
]
