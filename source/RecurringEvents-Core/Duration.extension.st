Extension { #name : 'Duration' }

{ #category : '*recurringevents-core' }
Duration >> asTemporalExpression [
	^ REDurationExpression new
		duration: self
]
