"
A rule that repeats from an anchor: what somebody means by 'every Monday at 9:00 in Berlin,
from 9 November on'. iCalendar writes it as DTSTART;TZID=... followed by an RRULE.

The anchor is an REZonedDateAndTime. It gives the first day, the time of day and the zone.
The rule is an RETemporalExpression over calendar days: it says which days, not at what
time. An occurrence is a day the rule includes, from the day of the anchor on, at the time
of day of the anchor in its zone -- 9:00 is 9:00 in Berlin in winter and in summer, and on
the days the clock changes the anchor's zone answers as RFC 5545 does. As in RFC 5545 the
anchor should be on a day the rule includes; when it is not, I do not add it. Without a rule
the anchor is the only occurrence.

I answer moments for moments (#nextOccurrenceAfter:). In between I work on local times: the
rule is asked about the date and time a clock in my zone shows, as a DateAndTime with offset
zero, and only the day it picks is turned back into a moment, at the anchor's time of day.
Dates inside the rule -- the start of an interval, the bounds of a range -- are read the same
way, as local times in my zone with offset zero. A rule that repeats within a day is not a
rule over days; of its occurrences only the days count.

In JSON I am the anchor as RFC 9557 under 'start' and the rule under 'rule':
{""start"": ""2026-11-09T09:00:00+01:00[Europe/Berlin]"", ""rule"": {""type"": ""dayInWeek"", ...}}
"
Class {
	#name : 'RERecurrence',
	#superclass : 'Object',
	#instVars : [
		'anchor',
		'rule'
	],
	#category : 'RecurringEvents-Core',
	#package : 'RecurringEvents-Core'
}

{ #category : 'instance creation' }
RERecurrence class >> anchor: aZonedDateAndTime [
	"the anchor as the only occurrence"

	^ self anchor: aZonedDateAndTime rule: nil
]

{ #category : 'instance creation' }
RERecurrence class >> anchor: aZonedDateAndTime rule: aTemporalExpressionOrNil [

	^ self new setAnchor: aZonedDateAndTime rule: aTemporalExpressionOrNil
]

{ #category : 'json' }
RERecurrence class >> fromJsonDict: aDict [

	^ self
		anchor: (REZonedDateAndTime fromString: (aDict at: 'start'))
		rule: ((aDict includesKey: 'rule') ifTrue: [
				 RETemporalExpression fromJsonDict: (aDict at: 'rule') ])
]

{ #category : 'json' }
RERecurrence class >> fromJsonString: aString [

	^ self fromJsonDict: (STONJSON fromString: aString)
]

{ #category : 'accessing' }
RERecurrence >> anchor [

	^ anchor
]

{ #category : 'json' }
RERecurrence >> asJsonDict [

	| dict |
	dict := Dictionary new.
	dict at: 'start' put: anchor printString.
	rule ifNotNil: [ dict at: 'rule' put: rule asJsonDict ].
	^ dict
]

{ #category : 'json' }
RERecurrence >> asJsonString [

	^ STONJSON toString: self asJsonDict
]

{ #category : 'private' }
RERecurrence >> firstDayAfter: aDateAndTime [
	"the local time whose day is the first an occurrence after the moment aDateAndTime can
	fall on: the day aDateAndTime is in my zone, but not before the day of my anchor"

	^ (REZonedDateAndTime at: aDateAndTime zoneId: anchor zoneId) localDateAndTime max:
		  anchor localDateAndTime
]

{ #category : 'private' }
RERecurrence >> localTimeOn: aDateAndTime [
	"the time of day of my anchor on the day aDateAndTime shows, with offset zero like every
	local time I hand the rule"

	| time |
	time := anchor localDateAndTime.
	^ DateAndTime
		  year: aDateAndTime year
		  month: aDateAndTime month
		  day: aDateAndTime dayOfMonth
		  hour: time hour
		  minute: time minute
		  second: time second
		  nanoSecond: time nanoSecond
		  offset: Duration zero
]

{ #category : 'accessing' }
RERecurrence >> nextOccurrenceAfter: aDateAndTime [
	"the first occurrence strictly after the moment aDateAndTime, as a moment shown with the
	offset my zone has then, or nil when there is none. The rule is asked from the day before
	the first day that can count, so that this day itself can be its answer. What the rule
	answers is used for its day only: an interval of months answers the first of a month at
	midnight"

	| probe found local moment |
	rule ifNil: [
		moment := anchor asDateAndTime.
		^ moment > aDateAndTime ifTrue: [ moment ] ].
	probe := (self localTimeOn: (self firstDayAfter: aDateAndTime)) - (Duration days: 1).
	[
	found := rule nextOccurrenceAfter: probe.
	found ifNil: [ ^ nil ].
	local := self localTimeOn: found.
	(local > probe and: [ rule includes: local ]) ifTrue: [
		moment := (REZonedDateAndTime local: local zoneId: anchor zoneId) asDateAndTime.
		moment > aDateAndTime ifTrue: [ ^ moment ] ].
	probe := found max: local ] repeat
]

{ #category : 'printing' }
RERecurrence >> printOn: aStream [

	aStream print: anchor.
	rule ifNotNil: [ aStream print: rule ]
]

{ #category : 'accessing' }
RERecurrence >> rule [

	^ rule
]

{ #category : 'initialization' }
RERecurrence >> setAnchor: aZonedDateAndTime rule: aTemporalExpressionOrNil [

	anchor := aZonedDateAndTime.
	rule := aTemporalExpressionOrNil
]
