Class {
	#name : 'RECalendarFileTest',
	#superclass : 'TestCase',
	#category : 'RecurringEvents-Tests',
	#package : 'RecurringEvents-Tests'
}

{ #category : 'tests' }
RECalendarFileTest >> testParsesBareVeventWithoutVCalendarWrapper [
	| tree |
	tree := RETemporalExpression fromICalendarString: 'BEGIN:VEVENT
DTSTART:20260803T090000
RRULE:FREQ=WEEKLY;BYDAY=MO
END:VEVENT'.
	self assert: (tree includes: (DateAndTime year: 2026 month: 8 day: 3 hour: 9 minute: 0 second: 0)).
	self deny: (tree includes: (DateAndTime year: 2026 month: 8 day: 4 hour: 9 minute: 0 second: 0))
]

{ #category : 'tests' }
RECalendarFileTest >> testParsesDateOnlyAndDateTimeValues [
	self assert: (RETemporalExpression parseICalendarDateTime: '20260615') equals: (DateAndTime year: 2026 month: 6 day: 15).
	self assert: (RETemporalExpression parseICalendarDateTime: '20260615T093000') equals: (DateAndTime year: 2026 month: 6 day: 15 hour: 9 minute: 30 second: 0).
	self assert: (RETemporalExpression parseICalendarDateTime: '20260615T093000Z') equals: (DateAndTime year: 2026 month: 6 day: 15 hour: 9 minute: 30 second: 0)
]

{ #category : 'tests' }
RECalendarFileTest >> testParsesFullVCalendarWithTzidAndExdate [
	"Realistic Thanksgiving VEVENT wrapped in a VCALENDAR, DTSTART carrying a TZID (ignored -
	naive datetime, same stance as the rest of this library) and folded SUMMARY line, plus
	an EXDATE excluding one future occurrence."
	| ics tree noon |
	ics := 'BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Test//EN
BEGIN:VEVENT
UID:thanksgiving-2026@example.com
DTSTAMP:20260101T000000Z
DTSTART;TZID=America/New_York:20261126T120000
SUMMARY:Thanksgiving
 dinner
RRULE:FREQ=YEARLY;BYMONTH=11;BYDAY=4TH
EXDATE:20271125T120000
END:VEVENT
END:VCALENDAR'.
	tree := RETemporalExpression fromICalendarString: ics.
	noon := #(0 0).
	self assert: (tree includes: (DateAndTime year: 2026 month: 11 day: 26 hour: 12 minute: 0 second: 0)).
	self deny: (tree includes: (DateAndTime year: 2027 month: 11 day: 25 hour: 12 minute: 0 second: 0)).
	self assert: (tree includes: (DateAndTime year: 2028 month: 11 day: 23 hour: 12 minute: 0 second: 0))
]

{ #category : 'tests' }
RECalendarFileTest >> testParsesNonRecurringSingleOccurrenceVevent [
	| tree |
	tree := RETemporalExpression fromICalendarString: 'BEGIN:VEVENT
DTSTART:20260615T100000
SUMMARY:One-off meeting
END:VEVENT'.
	self assert: (tree includes: (DateAndTime year: 2026 month: 6 day: 15 hour: 10 minute: 0 second: 0)).
	self deny: (tree includes: (DateAndTime year: 2026 month: 6 day: 22 hour: 10 minute: 0 second: 0))
]

{ #category : 'tests' }
RECalendarFileTest >> testParsesPropertyLineIgnoringParams [
	| parsed |
	parsed := RETemporalExpression parseICalendarPropertyLine: 'DTSTART;TZID=Europe/Berlin:20260101T090000'.
	self assert: parsed first equals: 'DTSTART'.
	self assert: parsed second equals: '20260101T090000'
]

{ #category : 'tests' }
RECalendarFileTest >> testParsesRdateWithMultipleValuesOnOneLine [
	| tree |
	tree := RETemporalExpression fromICalendarString: 'BEGIN:VEVENT
DTSTART:20260803T090000
RRULE:FREQ=WEEKLY;BYDAY=MO
RDATE:20260805T090000,20260806T090000
END:VEVENT'.
	self assert: (tree includes: (DateAndTime year: 2026 month: 8 day: 5 hour: 9 minute: 0 second: 0)).
	self assert: (tree includes: (DateAndTime year: 2026 month: 8 day: 6 hour: 9 minute: 0 second: 0))
]

{ #category : 'tests' }
RECalendarFileTest >> testRoundTripThanksgivingWithExdateThroughFullIcs [
	| dtstart tree written writtenTree |
	dtstart := DateAndTime year: 2026 month: 11 day: 26 hour: 12 minute: 0 second: 0.
	tree := RETemporalExpression fromICalendarString: 'BEGIN:VEVENT
DTSTART:20261126T120000
RRULE:FREQ=YEARLY;BYMONTH=11;BYDAY=4TH
EXDATE:20271125T120000
END:VEVENT'.
	written := tree asICalendarStringWithUid: 't@example.com' dtstamp: (DateAndTime year: 2026 month: 1 day: 1) dtstart: dtstart.
	writtenTree := RETemporalExpression fromICalendarString: written.
	self assert: (writtenTree includes: dtstart).
	self deny: (writtenTree includes: (DateAndTime year: 2027 month: 11 day: 25 hour: 12 minute: 0 second: 0)).
	self assert: (writtenTree includes: (DateAndTime year: 2028 month: 11 day: 23 hour: 12 minute: 0 second: 0))
]

{ #category : 'tests' }
RECalendarFileTest >> testUnfoldsFoldedLines [
	| lines |
	lines := RETemporalExpression unfoldICalendarLines: 'BEGIN:VEVENT
SUMMARY:A very long summary that
 continues here
END:VEVENT'.
	self assert: lines asArray equals: #('BEGIN:VEVENT' 'SUMMARY:A very long summary thatcontinues here' 'END:VEVENT')
]

{ #category : 'tests' }
RECalendarFileTest >> testWriterOutputStartsWithVcalendarWrapper [
	| tree written |
	tree := RETemporalExpression fromICalendarString: 'BEGIN:VEVENT
DTSTART:20260803T090000
RRULE:FREQ=WEEKLY;BYDAY=MO
END:VEVENT'.
	written := tree asICalendarStringWithUid: 'x@y' dtstamp: DateAndTime now dtstart: (DateAndTime year: 2026 month: 8 day: 3 hour: 9 minute: 0 second: 0).
	self assert: (written beginsWith: 'BEGIN:VCALENDAR').
	self assert: (written endsWith: 'END:VCALENDAR')
]

{ #category : 'tests' }
RECalendarFileTest >> testWritesCrlfLineEndings [
	| tree written |
	tree := RETemporalExpression fromICalendarString: 'BEGIN:VEVENT
DTSTART:20260803T090000
RRULE:FREQ=WEEKLY;BYDAY=MO
END:VEVENT'.
	written := tree asICalendarStringWithUid: 'x@y' dtstamp: DateAndTime now dtstart: (DateAndTime year: 2026 month: 8 day: 3 hour: 9 minute: 0 second: 0).
	self assert: (written occurrencesOf: Character cr) equals: (written occurrencesOf: Character lf).
	self assert: (written occurrencesOf: Character cr) > 0
]
