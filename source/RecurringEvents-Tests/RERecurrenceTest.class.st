"
Recurrences in Europe/Berlin. Summer time begins on 2027-03-28 at 02:00 (the clock jumps to
03:00) and ends on 2026-10-25 at 03:00 (the clock goes back to 02:00); both are Sundays.
2026-11-09 is a Monday.
"
Class {
	#name : 'RERecurrenceTest',
	#superclass : 'TestCase',
	#category : 'RecurringEvents-Tests',
	#package : 'RecurringEvents-Tests'
}

{ #category : 'helpers' }
RERecurrenceTest >> every: aWeekdaySymbol from: aString [

	^ RERecurrence
		  anchor: (self zoned: aString)
		  rule: (REDayInWeekExpression new weekdays: { aWeekdaySymbol })
]

{ #category : 'helpers' }
RERecurrenceTest >> local: aString [
	"a local time as the rule sees it, with offset zero"

	^ (self zoned: aString , '[Europe/Berlin]') localDateAndTime
]

{ #category : 'helpers' }
RERecurrenceTest >> moment: aString [

	^ DateAndTime fromString: aString
]

{ #category : 'helpers' }
RERecurrenceTest >> zoned: aString [

	^ REZonedDateAndTime fromString: aString
]

{ #category : 'tests' }
RERecurrenceTest >> testAMondayAfterTheClockChangeIsStillNineInBerlin [

	self
		assert: ((self every: #Monday from: '2026-11-09T09:00:00[Europe/Berlin]')
				 nextOccurrenceAfter: (self moment: '2027-03-22T08:00:00Z'))
		equals: (self moment: '2027-03-29T07:00:00Z')
]

{ #category : 'tests' }
RERecurrenceTest >> testARuleThatEndsHasNoOccurrenceAfterItsEnd [

	| recurrence |
	recurrence := RERecurrence
		              anchor: (self zoned: '2026-11-09T09:00:00[Europe/Berlin]')
		              rule: (REIntersectionTemporalExpression new expressions: {
					               (REDayInWeekExpression new weekdays: #( #Monday )).
					               (REAbsoluteRangeExpression new
						                from: nil
						                to: (self local: '2026-11-24T00:00:00')) }).
	self
		assert: (recurrence nextOccurrenceAfter: (self moment: '2026-11-16T08:00:00Z'))
		equals: (self moment: '2026-11-23T08:00:00Z').
	self assert: (recurrence nextOccurrenceAfter: (self moment: '2026-11-23T08:00:00Z')) isNil
]

{ #category : 'tests' }
RERecurrenceTest >> testATimeTheClockJumpsOverIsTakenWithTheOffsetBeforeTheJump [
	"02:30 does not exist on 2027-03-28; it is read with +01:00, the moment that is 03:30
	summer time"

	self
		assert: ((self every: #Sunday from: '2027-03-21T02:30:00[Europe/Berlin]')
				 nextOccurrenceAfter: (self moment: '2027-03-21T02:00:00Z'))
		equals: (self moment: '2027-03-28T01:30:00Z')
]

{ #category : 'tests' }
RERecurrenceTest >> testATimeThatComesTwiceOccursOnceAtTheFirst [
	"02:30 comes twice on 2026-10-25, at 00:30Z and at 01:30Z; the second is no occurrence"

	| recurrence |
	recurrence := self every: #Sunday from: '2026-10-18T02:30:00[Europe/Berlin]'.
	self
		assert: (recurrence nextOccurrenceAfter: (self moment: '2026-10-18T12:00:00Z'))
		equals: (self moment: '2026-10-25T00:30:00Z').
	self
		assert: (recurrence nextOccurrenceAfter: (self moment: '2026-10-25T00:30:00Z'))
		equals: (self moment: '2026-11-01T01:30:00Z')
]

{ #category : 'tests' }
RERecurrenceTest >> testAnEndBeforeTheTimeOfDayKeepsThatDayOut [
	"the interval answers 1 February at midnight, which is before the end; 9:00 is not"

	| recurrence |
	recurrence := RERecurrence
		              anchor: (self zoned: '2026-11-01T09:00:00[Europe/Berlin]')
		              rule: (REIntersectionTemporalExpression new expressions: {
					               (REIntervalExpression new
						                start: (self local: '2026-11-01T09:00:00')
						                unit: #month
						                interval: 3).
					               (REDayInMonthExpression new day: 1).
					               (REAbsoluteRangeExpression new
						                from: nil
						                to: (self local: '2027-02-01T05:00:00')) }).
	self assert: (recurrence nextOccurrenceAfter: (self moment: '2026-11-01T08:00:00Z')) isNil
]

{ #category : 'tests' }
RERecurrenceTest >> testAnIntervalOfMonthsKeepsTheTimeOfTheAnchor [
	"every third month on the first: the interval answers the first of a month at midnight,
	and the occurrence is at 9:00 nonetheless -- in winter and in summer"

	| recurrence |
	recurrence := RERecurrence
		              anchor: (self zoned: '2026-11-01T09:00:00[Europe/Berlin]')
		              rule: (REIntersectionTemporalExpression new expressions: {
					               (REIntervalExpression new
						                start: (self local: '2026-11-01T09:00:00')
						                unit: #month
						                interval: 3).
					               (REDayInMonthExpression new day: 1) }).
	self
		assert: (recurrence nextOccurrenceAfter: (self moment: '2026-11-01T08:00:00Z'))
		equals: (self moment: '2027-02-01T08:00:00Z').
	self
		assert: (recurrence nextOccurrenceAfter: (self moment: '2027-02-01T08:00:00Z'))
		equals: (self moment: '2027-05-01T07:00:00Z')
]

{ #category : 'tests' }
RERecurrenceTest >> testAnOccurrenceIsNotAfterItself [

	self
		assert: ((self every: #Monday from: '2026-11-09T09:00:00[Europe/Berlin]')
				 nextOccurrenceAfter: (self moment: '2026-11-16T08:00:00Z'))
		equals: (self moment: '2026-11-23T08:00:00Z')
]

{ #category : 'tests' }
RERecurrenceTest >> testEveryOtherMondayCountsFromTheAnchor [

	| recurrence |
	recurrence := RERecurrence
		              anchor: (self zoned: '2026-11-09T09:00:00[Europe/Berlin]')
		              rule: (REIntersectionTemporalExpression new expressions: {
					               (REIntervalExpression new
						                start: (self local: '2026-11-09T09:00:00')
						                unit: #week
						                interval: 2).
					               (REDayInWeekExpression new weekdays: #( #Monday )) }).
	self
		assert: (recurrence nextOccurrenceAfter: (self moment: '2026-11-09T08:00:00Z'))
		equals: (self moment: '2026-11-23T08:00:00Z').
	self
		assert: (recurrence nextOccurrenceAfter: (self moment: '2026-11-23T08:00:00Z'))
		equals: (self moment: '2026-12-07T08:00:00Z')
]

{ #category : 'tests' }
RERecurrenceTest >> testItIsWrittenAsJsonAndReadBackAsItself [

	| recurrence read |
	recurrence := RERecurrence
		              anchor: (self zoned: '2026-11-09T09:00:00[Europe/Berlin]')
		              rule: (REIntersectionTemporalExpression new expressions: {
					               (REIntervalExpression new
						                start: (self local: '2026-11-09T09:00:00')
						                unit: #week
						                interval: 2).
					               (REDayInWeekExpression new weekdays: #( #Monday )) }).
	read := RERecurrence fromJsonString: recurrence asJsonString.
	self
		assert: (recurrence asJsonDict at: 'start')
		equals: '2026-11-09T09:00:00+01:00[Europe/Berlin]'.
	self assert: read asJsonDict equals: recurrence asJsonDict.
	self
		assert: (read nextOccurrenceAfter: (self moment: '2026-11-09T08:00:00Z'))
		equals: (self moment: '2026-11-23T08:00:00Z')
]

{ #category : 'tests' }
RERecurrenceTest >> testNothingOccursBeforeTheDayOfTheAnchor [

	self
		assert: ((self every: #Monday from: '2026-11-18T09:00:00[Europe/Berlin]')
				 nextOccurrenceAfter: (self moment: '2026-11-09T00:00:00Z'))
		equals: (self moment: '2026-11-23T08:00:00Z')
]

{ #category : 'tests' }
RERecurrenceTest >> testTheSameDayCountsWhileItsTimeIsStillAhead [

	self
		assert: ((self every: #Monday from: '2026-11-09T09:00:00[Europe/Berlin]')
				 nextOccurrenceAfter: (self moment: '2026-11-16T07:00:00Z'))
		equals: (self moment: '2026-11-16T08:00:00Z')
]

{ #category : 'tests' }
RERecurrenceTest >> testTheTimeOfDayComesFromTheAnchorNotFromTheMomentAskedAfter [
	"asked on a Wednesday at 10:23, the next Monday is at 9:00"

	self
		assert: ((self every: #Monday from: '2026-11-09T09:00:00[Europe/Berlin]')
				 nextOccurrenceAfter: (self moment: '2026-11-11T09:23:00Z'))
		equals: (self moment: '2026-11-16T08:00:00Z')
]

{ #category : 'tests' }
RERecurrenceTest >> testWithoutARuleTheAnchorIsTheOnlyOccurrence [

	| recurrence |
	recurrence := RERecurrence anchor: (self zoned: '2026-11-20T15:00:00[Europe/Berlin]').
	self
		assert: (recurrence nextOccurrenceAfter: (self moment: '2026-11-10T00:00:00Z'))
		equals: (self moment: '2026-11-20T14:00:00Z').
	self assert: (recurrence nextOccurrenceAfter: (self moment: '2026-11-20T14:00:00Z')) isNil.
	self assert: (recurrence asJsonDict keys) asArray equals: #( 'start' )
]
