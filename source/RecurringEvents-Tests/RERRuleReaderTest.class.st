Class {
	#name : 'RERRuleReaderTest',
	#superclass : 'TestCase',
	#category : 'RecurringEvents-Tests',
	#package : 'RecurringEvents-Tests'
}

{ #category : 'tests' }
RERRuleReaderTest >> testCountRaisesNotYetSupportedError [
	self should: [ RETemporalExpression fromRRuleString: 'FREQ=WEEKLY;COUNT=5' dtstart: DateAndTime now ]
		raise: Error
]

{ #category : 'tests' }
RERRuleReaderTest >> testExdatesExcludeSpecificOccurrences [
	| expr |
	expr := RETemporalExpression
		fromRRuleString: 'FREQ=WEEKLY;BYDAY=MO'
		dtstart: (DateAndTime year: 2026 month: 8 day: 3)
		exdates: { DateAndTime year: 2026 month: 8 day: 10 }
		rdates: nil.
	self deny: (expr includes: (DateAndTime year: 2026 month: 8 day: 10)).
	self assert: (expr includes: (DateAndTime year: 2026 month: 8 day: 17))
]

{ #category : 'tests' }
RERRuleReaderTest >> testLastWorkdayOfMonthMonthlyByDayBySetPos [
	| expr |
	expr := RETemporalExpression fromRRuleString: 'FREQ=MONTHLY;BYDAY=MO,TU,WE,TH,FR;BYSETPOS=-1' dtstart: (DateAndTime year: 2026 month: 1 day: 30).
	self assert: (expr includes: (DateAndTime year: 2026 month: 2 day: 27)).
	self deny: (expr includes: (DateAndTime year: 2026 month: 2 day: 28))
]

{ #category : 'tests' }
RERRuleReaderTest >> testMonthlyByMonthDayWithUntil [
	| expr |
	expr := RETemporalExpression fromRRuleString: 'FREQ=MONTHLY;BYMONTHDAY=1;UNTIL=20261231' dtstart: (DateAndTime year: 2026 month: 1 day: 1).
	self assert: (expr includes: (DateAndTime year: 2026 month: 12 day: 1)).
	self deny: (expr includes: (DateAndTime year: 2027 month: 1 day: 1))
]

{ #category : 'tests' }
RERRuleReaderTest >> testNoByRulePartDefaultsToDtstartDayOfMonth [
	"RFC 5545: FREQ=MONTHLY with no BYDAY/BYMONTHDAY defaults to DTSTARTs own day-of-month,
	NOT every day of the month - a real bug caught while building this reader."
	| expr |
	expr := RETemporalExpression fromRRuleString: 'FREQ=MONTHLY' dtstart: (DateAndTime year: 2026 month: 1 day: 15).
	self assert: (expr includes: (DateAndTime year: 2026 month: 3 day: 15)).
	self deny: (expr includes: (DateAndTime year: 2026 month: 3 day: 16))
]

{ #category : 'tests' }
RERRuleReaderTest >> testNoByRulePartDefaultsToDtstartDayOfYear [
	| expr |
	expr := RETemporalExpression fromRRuleString: 'FREQ=YEARLY' dtstart: (DateAndTime year: 2026 month: 5 day: 25).
	self assert: (expr includes: (DateAndTime year: 2027 month: 5 day: 25)).
	self deny: (expr includes: (DateAndTime year: 2027 month: 5 day: 26))
]

{ #category : 'tests' }
RERRuleReaderTest >> testPlainWeeklyDefaultsCorrectly [
	| expr |
	expr := RETemporalExpression fromRRuleString: 'FREQ=WEEKLY;BYDAY=MO' dtstart: (DateAndTime year: 2026 month: 8 day: 3).
	self assert: (expr includes: (DateAndTime year: 2026 month: 8 day: 10)).
	self deny: (expr includes: (DateAndTime year: 2026 month: 8 day: 11))
]

{ #category : 'tests' }
RERRuleReaderTest >> testRdatesAddExtraOccurrences [
	| expr |
	expr := RETemporalExpression
		fromRRuleString: 'FREQ=WEEKLY;BYDAY=MO'
		dtstart: (DateAndTime year: 2026 month: 8 day: 3)
		exdates: nil
		rdates: { DateAndTime year: 2026 month: 8 day: 6 }.
	self assert: (expr includes: (DateAndTime year: 2026 month: 8 day: 6)).
	self assert: (expr includes: (DateAndTime year: 2026 month: 8 day: 3))
]

{ #category : 'tests' }
RERRuleReaderTest >> testThanksgivingYearlyByMonthOrdinalByDay [
	"FREQ=YEARLY;BYMONTH=11;BYDAY=4TH - the ordinal must count within November, not the whole year."
	| expr |
	expr := RETemporalExpression fromRRuleString: 'FREQ=YEARLY;BYMONTH=11;BYDAY=4TH' dtstart: (DateAndTime year: 2026 month: 11 day: 26).
	self assert: (expr includes: (DateAndTime year: 2026 month: 11 day: 26)).
	self deny: (expr includes: (DateAndTime year: 2026 month: 11 day: 19)).
	self assert: (expr includes: (DateAndTime year: 2027 month: 11 day: 25))
]

{ #category : 'tests' }
RERRuleReaderTest >> testUnsupportedSubDailyFreqRaisesError [
	self should: [ RETemporalExpression fromRRuleString: 'FREQ=DAILY' dtstart: DateAndTime now ]
		raise: Error
]

{ #category : 'tests' }
RERRuleReaderTest >> testWeeklyIntervalByDayWithWkst [
	"The classic RFC 5545 WKST textbook example, this time parsed from an actual RRULE string."
	| expr |
	expr := RETemporalExpression fromRRuleString: 'FREQ=WEEKLY;INTERVAL=2;BYDAY=TU,SU;WKST=SU' dtstart: (DateAndTime year: 2026 month: 8 day: 4).
	self assert: (expr includes: (DateAndTime year: 2026 month: 8 day: 4)).
	self deny: (expr includes: (DateAndTime year: 2026 month: 8 day: 9)).
	self assert: (expr includes: (DateAndTime year: 2026 month: 8 day: 16))
]

{ #category : 'tests' }
RERRuleReaderTest >> testYearlyByWeekNo [
	| expr |
	expr := RETemporalExpression fromRRuleString: 'FREQ=YEARLY;BYWEEKNO=1' dtstart: (DateAndTime year: 2026 month: 1 day: 1).
	self assert: (expr includes: (DateAndTime year: 2026 month: 1 day: 4)).
	self deny: (expr includes: (DateAndTime year: 2026 month: 1 day: 12))
]

{ #category : 'tests' }
RERRuleReaderTest >> testYearlyByYearDay [
	| expr |
	expr := RETemporalExpression fromRRuleString: 'FREQ=YEARLY;BYYEARDAY=1,-1' dtstart: (DateAndTime year: 2026 month: 1 day: 1).
	self assert: (expr includes: (DateAndTime year: 2026 month: 1 day: 1)).
	self assert: (expr includes: (DateAndTime year: 2026 month: 12 day: 31)).
	self deny: (expr includes: (DateAndTime year: 2026 month: 6 day: 1))
]
