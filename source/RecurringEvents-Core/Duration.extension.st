Extension { #name : 'Duration' }

{ #category : '*recurringevents-core' }
Duration >> asISO8601Duration [
	| stream hasTimePart |
	stream := WriteStream on: String new.
	stream nextPut: $P.
	self days > 0 ifTrue: [ stream print: self days; nextPut: $D ].
	hasTimePart := self hours > 0 or: [ self minutes > 0 or: [ self seconds > 0 ] ].
	hasTimePart ifTrue: [
		stream nextPut: $T.
		self hours > 0 ifTrue: [ stream print: self hours; nextPut: $H ].
		self minutes > 0 ifTrue: [ stream print: self minutes; nextPut: $M ].
		self seconds > 0 ifTrue: [ stream print: self seconds; nextPut: $S ] ].
	(self days = 0 and: [ hasTimePart not ]) ifTrue: [ stream nextPutAll: '0D' ].
	^ stream contents
]

{ #category : '*recurringevents-core' }
Duration >> asTemporalExpression [
	^ REDurationExpression new
		duration: self
]

{ #category : '*recurringevents-core' }
Duration class >> fromISO8601Duration: aString [
	"Parses the subset of ISO 8601 durations RecurringEvents needs: P[n]DT[n]H[n]M[n]S.
	No Y/M (year/month) units - those are calendar-relative and ambiguous as a fixed
	elapsed duration, and are handled instead by the calendar temporal expressions."
	| datePart timePart days hours minutes seconds numberStream digits |
	(aString first = $P) ifFalse: [ self error: 'Not an ISO 8601 duration: ' , aString ].
	datePart := (aString copyFrom: 2 to: aString size).
	(datePart includes: $T)
		ifTrue: [
			timePart := datePart copyFrom: (datePart indexOf: $T) + 1 to: datePart size.
			datePart := datePart copyFrom: 1 to: (datePart indexOf: $T) - 1 ]
		ifFalse: [ timePart := ''  ].
	days := 0.
	hours := 0.
	minutes := 0.
	seconds := 0.
	numberStream := WriteStream on: String new.
	datePart do: [ :ch |
		ch isDigit
			ifTrue: [ numberStream nextPut: ch ]
			ifFalse: [
				digits := numberStream contents.
				numberStream := WriteStream on: String new.
				ch = $D ifTrue: [ days := digits asNumber ] ] ].
	timePart do: [ :ch |
		ch isDigit
			ifTrue: [ numberStream nextPut: ch ]
			ifFalse: [
				digits := numberStream contents.
				numberStream := WriteStream on: String new.
				ch = $H ifTrue: [ hours := digits asNumber ].
				ch = $M ifTrue: [ minutes := digits asNumber ].
				ch = $S ifTrue: [ seconds := digits asNumber ] ] ].
	^ self days: days hours: hours minutes: minutes seconds: seconds
]
