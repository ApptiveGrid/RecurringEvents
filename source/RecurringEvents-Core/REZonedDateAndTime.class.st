"
A wall-clock time in a time zone: what somebody means by 'Monday 9:00 in Berlin'.

I hold the local date and time and the id of the zone, not an offset. The offset follows
from the zone at that moment -- +01:00 in winter, +02:00 in summer in Berlin -- and is
worked out when the moment is asked for (#asDateAndTime), from the zone database that
ZTimezone reads. That keeps me right when the rules of a zone change after I was
written, and it is why I do no arithmetic of my own: adding days to a DateAndTime keeps
its offset, and across the change to summer time that lands an hour off. Whoever wants
to move me moves the local time and makes a new one of me.

Not every local time is one moment, and I answer as RFC 5545 does:
- a time the clock jumps over is taken with the offset before the jump: 02:30 on the day
  summer time begins is 03:30 summer time;
- a time that comes twice, because the clock goes back, is the first of the two --
  unless I was given an offset that picks the other one (#fromString:).

I print in the form of RFC 9557, the moment with its offset and the zone in brackets:
2026-11-09T09:00:00+01:00[Europe/Berlin].
"
Class {
	#name : 'REZonedDateAndTime',
	#superclass : 'Object',
	#instVars : [
		'localDateAndTime',
		'zoneId',
		'givenOffset'
	],
	#category : 'RecurringEvents-Core',
	#package : 'RecurringEvents-Core'
}

{ #category : 'instance creation' }
REZonedDateAndTime class >> at: aDateAndTime zoneId: aString [
	"the moment aDateAndTime, as the local time it is in the zone aString. In the hour the
	clock goes back the moment says which of the two local times it is, and I keep that"

	| offset |
	offset := (ZTimezone id: aString) offsetForTimestamp: aDateAndTime.
	^ self new
		setLocal: (self wallClockOf: (aDateAndTime offset: offset))
		zoneId: aString
		offset: offset
]

{ #category : 'instance creation' }
REZonedDateAndTime class >> fromString: aString [
	"RFC 9557: a local date and time, optionally its offset, and the zone in brackets --
	2026-11-09T09:00:00[Europe/Berlin] or 2026-11-09T09:00:00+01:00[Europe/Berlin]. An
	offset has to be one the zone has at that local time; in the hour the clock goes back
	it picks which of the two"

	| open dateAndTimePart hasOffset parsed |
	open := aString indexOf: $[.
	(open = 0 or: [ aString last ~= $] ]) ifTrue: [
		^ self error: 'no time zone in brackets: ' , aString ].
	dateAndTimePart := aString copyFrom: 1 to: open - 1.
	hasOffset := self hasOffset: dateAndTimePart.
	"read without an offset, DateAndTime would take the image's own"
	parsed := DateAndTime fromString: (hasOffset
		ifTrue: [ dateAndTimePart ]
		ifFalse: [ dateAndTimePart , 'Z' ]).
	^ self new
		setLocal: (self wallClockOf: parsed)
		zoneId: (aString copyFrom: open + 1 to: aString size - 1)
		offset: (hasOffset ifTrue: [ parsed offset ])
]

{ #category : 'private' }
REZonedDateAndTime class >> hasOffset: aString [
	"whether the time in aString ends in Z or carries a +hh:mm or -hh:mm"

	| time |
	time := aString copyAfter: $T.
	^ time notEmpty and: [
		  time last = $Z or: [ (time includes: $+) or: [ time includes: $- ] ] ]
]

{ #category : 'instance creation' }
REZonedDateAndTime class >> local: aDateAndTime zoneId: aString [
	"the date and time aDateAndTime shows, read as the local time in the zone aString. Its
	own offset is not looked at"

	^ self new
		setLocal: (self wallClockOf: aDateAndTime)
		zoneId: aString
		offset: nil
]

{ #category : 'private' }
REZonedDateAndTime class >> wallClockOf: aDateAndTime [
	"the date and time aDateAndTime shows, with no offset: a local time that is not yet a
	moment"

	^ DateAndTime
		year: aDateAndTime year
		month: aDateAndTime month
		day: aDateAndTime dayOfMonth
		hour: aDateAndTime hour
		minute: aDateAndTime minute
		second: aDateAndTime second
		nanoSecond: aDateAndTime nanoSecond
		offset: Duration zero
]

{ #category : 'comparing' }
REZonedDateAndTime >> = anObject [

	^ self class = anObject class and: [
		  localDateAndTime = anObject localDateAndTime and: [
			  zoneId = anObject zoneId and: [ self offset = anObject offset ] ] ]
]

{ #category : 'converting' }
REZonedDateAndTime >> asDateAndTime [
	"the moment I stand for, shown with the offset my zone has at that moment"

	| moment |
	moment := localDateAndTime - self offset.
	^ moment offset: (self zone offsetForTimestamp: moment)
]

{ #category : 'comparing' }
REZonedDateAndTime >> hash [

	^ localDateAndTime hash bitXor: zoneId hash
]

{ #category : 'accessing' }
REZonedDateAndTime >> localDateAndTime [
	"my date and time as a clock in my zone shows it, as a DateAndTime with no offset"

	^ localDateAndTime
]

{ #category : 'accessing' }
REZonedDateAndTime >> offset [
	"the offset my local time has in my zone: the one I was given, else the one the zone
	has then. In the hour the clock goes back there are two, and the first moment is the
	one with the larger offset. In the hour it jumps over there is none, and ZTimezone
	answers the offset before the jump"

	| valid |
	givenOffset ifNotNil: [ ^ givenOffset ].
	valid := self validOffsets.
	valid isEmpty ifTrue: [ ^ self zone offsetForLocalTimestamp: localDateAndTime ].
	^ valid inject: valid anyOne into: [ :largest :each | largest max: each ]
]

{ #category : 'printing' }
REZonedDateAndTime >> printOn: aStream [

	aStream
		print: self asDateAndTime;
		nextPut: $[;
		nextPutAll: zoneId;
		nextPut: $]
]

{ #category : 'initialization' }
REZonedDateAndTime >> setLocal: aDateAndTime zoneId: aString offset: aDurationOrNil [

	localDateAndTime := aDateAndTime.
	zoneId := aString.
	givenOffset := aDurationOrNil.
	self zone.
	(givenOffset isNil or: [ self validOffsets includes: givenOffset ]) ifFalse: [
		self error: 'the zone ' , zoneId , ' has no offset ' , givenOffset printString , ' at '
			, localDateAndTime printString ]
]

{ #category : 'private' }
REZonedDateAndTime >> validOffsets [
	"the offsets under which my local time is a moment of my zone: one as a rule, two in
	the hour the clock goes back, none in the hour it jumps over. A day either side covers
	any change of the clock that could be near"

	| zone |
	zone := self zone.
	^ {
		  (zone offsetForTimestamp: localDateAndTime - (Duration days: 1)).
		  (zone offsetForTimestamp: localDateAndTime + (Duration days: 1)).
		  (zone offsetForLocalTimestamp: localDateAndTime) } asSet select: [ :each |
		  (zone offsetForTimestamp: localDateAndTime - each) = each ]
]

{ #category : 'accessing' }
REZonedDateAndTime >> zone [
	"the zone, from ZTimezone's cache once it was read. Not kept on me: what I store is the
	id, and the rules behind it can change"

	^ ZTimezone id: zoneId
]

{ #category : 'accessing' }
REZonedDateAndTime >> zoneId [

	^ zoneId
]
