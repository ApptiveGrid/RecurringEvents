Class {
	#name : 'RERRuleWriterTest',
	#superclass : 'TestCase',
	#category : 'RecurringEvents-Tests',
	#package : 'RecurringEvents-Tests'
}

{ #category : 'tests' }
RERRuleWriterTest >> testRaisesErrorForNonRepresentableTree [
	"RERangeEachYearExpression (an arbitrary recurring month/day range) has no RRULE
	equivalent at all - the writer must fail clearly, not silently produce something wrong."
	| expr |
	expr := RERangeEachYearExpression new startMonth: 6 startDay: 1 endMonth: 8 endDay: 31.
	self should: [ expr asRRuleString ] raise: Error
]

{ #category : 'tests' }
RERRuleWriterTest >> testRoundTripLastWorkdayOfMonth [
	| dtstart tree writtenTree |
	dtstart := DateAndTime year: 2026 month: 1 day: 30.
	tree := RETemporalExpression fromRRuleString: 'FREQ=MONTHLY;BYDAY=MO,TU,WE,TH,FR;BYSETPOS=-1' dtstart: dtstart.
	writtenTree := RETemporalExpression fromRRuleString: tree asRRuleString dtstart: dtstart.
	self assert: (writtenTree includes: (DateAndTime year: 2026 month: 2 day: 27)).
	self deny: (writtenTree includes: (DateAndTime year: 2026 month: 2 day: 28))
]

{ #category : 'tests' }
RERRuleWriterTest >> testRoundTripThanksgiving [
	| dtstart tree writtenTree |
	dtstart := DateAndTime year: 2026 month: 11 day: 26.
	tree := RETemporalExpression fromRRuleString: 'FREQ=YEARLY;BYMONTH=11;BYDAY=4TH' dtstart: dtstart.
	writtenTree := RETemporalExpression fromRRuleString: tree asRRuleString dtstart: dtstart.
	self assert: (writtenTree includes: (DateAndTime year: 2026 month: 11 day: 26)).
	self deny: (writtenTree includes: (DateAndTime year: 2026 month: 11 day: 19)).
	self assert: (writtenTree includes: (DateAndTime year: 2027 month: 11 day: 25))
]

{ #category : 'tests' }
RERRuleWriterTest >> testRoundTripWeeklyIntervalWithWkst [
	| dtstart tree writtenTree |
	dtstart := DateAndTime year: 2026 month: 8 day: 4.
	tree := RETemporalExpression fromRRuleString: 'FREQ=WEEKLY;INTERVAL=2;BYDAY=TU,SU;WKST=SU' dtstart: dtstart.
	writtenTree := RETemporalExpression fromRRuleString: tree asRRuleString dtstart: dtstart.
	self deny: (writtenTree includes: (DateAndTime year: 2026 month: 8 day: 9)).
	self assert: (writtenTree includes: (DateAndTime year: 2026 month: 8 day: 16))
]

{ #category : 'tests' }
RERRuleWriterTest >> testWritesDirectOrdinalDayInMonthComposition [
	"The pre-RESetPositionExpression way of building Thanksgiving (Intersection of MonthInYear +
	DayInMonth-ordinal directly, no RESetPositionExpression) must also be writable - the writer
	should not only understand what its own reader happens to produce."
	| expr |
	expr := REIntersectionTemporalExpression new expressions: {
		(REMonthInYearExpression new months: #(#November)).
		(REDayInMonthExpression new ordinal: 4 weekday: #Thursday) }.
	self assert: expr asRRuleString equals: 'FREQ=YEARLY;BYMONTH=11;BYDAY=4TH'
]

{ #category : 'tests' }
RERRuleWriterTest >> testWritesIntervalWithNonDefaultWkst [
	| expr |
	expr := REIntersectionTemporalExpression new expressions: {
		(REIntervalExpression new start: (DateAndTime year: 2026 month: 8 day: 4) unit: #week interval: 2; wkst: #Sunday; yourself).
		(REDayInWeekExpression new weekdays: #(#Tuesday #Sunday)) }.
	self assert: expr asRRuleString equals: 'FREQ=WEEKLY;INTERVAL=2;WKST=SU;BYDAY=TU,SU'
]

{ #category : 'tests' }
RERRuleWriterTest >> testWritesSimpleWeeklyByDay [
	| expr |
	expr := REDayInWeekExpression new weekdays: #(#Monday).
	self assert: expr asRRuleString equals: 'FREQ=WEEKLY;BYDAY=MO'
]

{ #category : 'tests' }
RERRuleWriterTest >> testWritesUntil [
	| expr |
	expr := REIntersectionTemporalExpression new expressions: {
		(REDayInMonthExpression new day: 1).
		(REAbsoluteRangeExpression new from: nil to: (DateAndTime year: 2027 month: 1 day: 1)) }.
	self assert: expr asRRuleString equals: 'FREQ=MONTHLY;BYMONTHDAY=1;UNTIL=20261231T235959Z'
]
