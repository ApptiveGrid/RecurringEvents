"
Local times in Europe/Berlin, the zone whose changes of the clock are best known here:
summer time begins on 2027-03-28 at 02:00 (the clock jumps to 03:00) and ends on
2026-10-25 at 03:00 (the clock goes back to 02:00).
"
Class {
	#name : 'REZonedDateAndTimeTest',
	#superclass : 'TestCase',
	#category : 'RecurringEvents-Tests',
	#package : 'RecurringEvents-Tests'
}

{ #category : 'helpers' }
REZonedDateAndTimeTest >> moment: aString [

	^ DateAndTime fromString: aString
]

{ #category : 'helpers' }
REZonedDateAndTimeTest >> zoned: aString [

	^ REZonedDateAndTime fromString: aString
]

{ #category : 'tests' }
REZonedDateAndTimeTest >> testAGivenOffsetPicksTheSecondOfTwo [

	self
		assert: (self zoned: '2026-10-25T02:30:00+01:00[Europe/Berlin]') asDateAndTime
		equals: (self moment: '2026-10-25T01:30:00Z')
]

{ #category : 'tests' }
REZonedDateAndTimeTest >> testAMomentKeepsWhichOfTwoLocalTimesItIs [
	"the second 02:30 of the night the clock goes back is a moment of its own, and it comes
	back as itself"

	| zoned |
	zoned := REZonedDateAndTime at: (self moment: '2026-10-25T01:30:00Z') zoneId: 'Europe/Berlin'.
	self assert: zoned localDateAndTime equals: (self moment: '2026-10-25T02:30:00Z').
	self assert: zoned asDateAndTime equals: (self moment: '2026-10-25T01:30:00Z')
]

{ #category : 'tests' }
REZonedDateAndTimeTest >> testAStringWithoutAZoneIsRefused [

	self should: [ self zoned: '2026-11-09T09:00:00+01:00' ] raise: Error
]

{ #category : 'tests' }
REZonedDateAndTimeTest >> testASummerMorningInBerlinIsTwoHoursAheadOfUTC [

	self
		assert: (self zoned: '2027-07-01T09:00:00[Europe/Berlin]') asDateAndTime
		equals: (self moment: '2027-07-01T07:00:00Z')
]

{ #category : 'tests' }
REZonedDateAndTimeTest >> testATimeTheClockJumpsOverIsTakenWithTheOffsetBeforeTheJump [
	"RFC 5545: 02:30 does not exist that night, and it is read with +01:00 -- the moment that
	is 03:30 summer time"

	self
		assert: (self zoned: '2027-03-28T02:30:00[Europe/Berlin]') asDateAndTime
		equals: (self moment: '2027-03-28T01:30:00Z')
]

{ #category : 'tests' }
REZonedDateAndTimeTest >> testATimeThatComesTwiceIsTheFirst [
	"RFC 5545: of the two 02:30 of that night, the one still in summer time"

	self
		assert: (self zoned: '2026-10-25T02:30:00[Europe/Berlin]') asDateAndTime
		equals: (self moment: '2026-10-25T00:30:00Z')
]

{ #category : 'tests' }
REZonedDateAndTimeTest >> testAWinterMorningInBerlinIsAnHourAheadOfUTC [

	self
		assert: (self zoned: '2026-11-09T09:00:00[Europe/Berlin]') asDateAndTime
		equals: (self moment: '2026-11-09T08:00:00Z')
]

{ #category : 'tests' }
REZonedDateAndTimeTest >> testAnOffsetTheZoneDoesNotHaveThenIsRefused [

	self should: [ self zoned: '2026-11-09T09:00:00+02:00[Europe/Berlin]' ] raise: Error
]

{ #category : 'tests' }
REZonedDateAndTimeTest >> testAnUnknownZoneIsRefused [

	self should: [ self zoned: '2026-11-09T09:00:00[Nowhere/Nothing]' ] raise: Error
]

{ #category : 'tests' }
REZonedDateAndTimeTest >> testItPrintsAsRFC9557AndIsReadBackAsItself [

	| zoned |
	zoned := self zoned: '2026-11-09T09:00:00[Europe/Berlin]'.
	self assert: zoned printString equals: '2026-11-09T09:00:00+01:00[Europe/Berlin]'.
	self assert: (self zoned: zoned printString) equals: zoned
]

{ #category : 'tests' }
REZonedDateAndTimeTest >> testTheLocalTimeIgnoresTheOffsetOfWhatItIsMadeFrom [
	"9:00 is 9:00 in Berlin, whatever offset the DateAndTime it was read off carried"

	self
		assert: (REZonedDateAndTime local: (self moment: '2026-11-09T09:00:00+05:00') zoneId: 'Europe/Berlin') asDateAndTime
		equals: (self moment: '2026-11-09T08:00:00Z')
]
