Extension { #name : 'Duration' }

{ #category : '*recurringevents-common' }
Duration >> asTemporalExpression [
	^ REDurationExpression new
		duration: self
]
