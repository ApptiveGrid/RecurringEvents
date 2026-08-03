Class {
	#name : 'REIntervalExpressionTest',
	#superclass : 'TestCase',
	#category : 'RecurringEvents-Tests',
	#package : 'RecurringEvents-Tests'
}

{ #category : 'tests' }
REIntervalExpressionTest >> testCompositionWithDayInMonthGivesQuarterlyFirstOfMonth [
	"Every 3 months on the 1st, composed via Intersection like Fowlers other calendar expressions."
	| start everyThreeMonths firstOfMonth quarterly |
	start := DateAndTime year: 2026 month: 1 day: 1.
	everyThreeMonths := REIntervalExpression new start: start unit: #month interval: 3.
	firstOfMonth := REDayInMonthExpression new day: 1.
	quarterly := REIntersectionTemporalExpression new expressions: { everyThreeMonths. firstOfMonth }.
	self assert: (quarterly includes: (DateAndTime year: 2026 month: 4 day: 1)).
	self deny: (quarterly includes: (DateAndTime year: 2026 month: 2 day: 1)).
	self deny: (quarterly includes: (DateAndTime year: 2026 month: 4 day: 2)).
	self assert: (quarterly nextOccurrenceAfter: start) equals: (DateAndTime year: 2026 month: 4 day: 1)
]

{ #category : 'tests' }
REIntervalExpressionTest >> testExcludesBeforeStart [
	| start expr |
	start := DateAndTime year: 2026 month: 1 day: 1.
	expr := REIntervalExpression new start: start unit: #month interval: 3.
	self deny: (expr includes: start - (Duration days: 1))
]

{ #category : 'tests' }
REIntervalExpressionTest >> testExcludesNonMultipleMonth [
	| start expr |
	start := DateAndTime year: 2026 month: 1 day: 1.
	expr := REIntervalExpression new start: start unit: #month interval: 3.
	self deny: (expr includes: (DateAndTime year: 2026 month: 2 day: 1))
]

{ #category : 'tests' }
REIntervalExpressionTest >> testIncludesMultipleOfIntervalMonth [
	| start expr |
	start := DateAndTime year: 2026 month: 1 day: 1.
	expr := REIntervalExpression new start: start unit: #month interval: 3.
	self assert: (expr includes: (DateAndTime year: 2026 month: 4 day: 1))
]

{ #category : 'tests' }
REIntervalExpressionTest >> testIncludesStart [
	| start expr |
	start := DateAndTime year: 2026 month: 1 day: 1.
	expr := REIntervalExpression new start: start unit: #month interval: 3.
	self assert: (expr includes: start)
]

{ #category : 'tests' }
REIntervalExpressionTest >> testIncludesWholeMatchingMonth [
	"elapsed=0 for the whole of January, regardless of day-of-month."
	| start expr |
	start := DateAndTime year: 2026 month: 1 day: 1.
	expr := REIntervalExpression new start: start unit: #month interval: 3.
	self assert: (expr includes: (DateAndTime year: 2026 month: 1 day: 20))
]

{ #category : 'tests' }
REIntervalExpressionTest >> testNextOccurrenceBeforeStartReturnsStart [
	| start expr |
	start := DateAndTime year: 2026 month: 1 day: 1.
	expr := REIntervalExpression new start: start unit: #month interval: 3.
	self assert: (expr nextOccurrenceAfter: start - (Duration days: 5)) equals: start
]

{ #category : 'tests' }
REIntervalExpressionTest >> testNextOccurrenceSkipsNonMatchingMonths [
	| start expr lastDayOfJanuary |
	start := DateAndTime year: 2026 month: 1 day: 1.
	expr := REIntervalExpression new start: start unit: #month interval: 3.
	lastDayOfJanuary := DateAndTime year: 2026 month: 1 day: 31.
	self assert: (expr nextOccurrenceAfter: lastDayOfJanuary) equals: (DateAndTime year: 2026 month: 4 day: 1)
]

{ #category : 'tests' }
REIntervalExpressionTest >> testNextOccurrenceWithNilArgumentReturnsStart [
	| start expr |
	start := DateAndTime year: 2026 month: 1 day: 1.
	expr := REIntervalExpression new start: start unit: #month interval: 3.
	self assert: (expr nextOccurrenceAfter: nil) equals: start
]

{ #category : 'tests' }
REIntervalExpressionTest >> testNextOccurrenceWithinMatchingPeriodReturnsNextDay [
	| start expr |
	start := DateAndTime year: 2026 month: 1 day: 1.
	expr := REIntervalExpression new start: start unit: #month interval: 3.
	self assert: (expr nextOccurrenceAfter: start) equals: start + (Duration days: 1)
]

{ #category : 'tests' }
REIntervalExpressionTest >> testWeekIntervalCalendarAware [
	"Weeks are fixed 7-day blocks, but grouping matters once combined with multiple weekdays."
	| start expr |
	start := DateAndTime year: 2026 month: 1 day: 5. "a Monday"
	expr := REIntervalExpression new start: start unit: #week interval: 2.
	self assert: (expr includes: start).
	self assert: (expr includes: start + (Duration days: 6)). "still week 0 (the following Sunday)"
	self deny: (expr includes: start + (Duration days: 7)). "week 1, excluded"
	self assert: (expr includes: start + (Duration days: 14)) "week 2, included"
]

{ #category : 'tests' }
REIntervalExpressionTest >> testYearIntervalHandlesVariableMonthLengths [
	| start expr |
	start := DateAndTime year: 2024 month: 1 day: 1. "a leap year, deliberately"
	expr := REIntervalExpression new start: start unit: #year interval: 3.
	self deny: (expr includes: (DateAndTime year: 2025 month: 6 day: 1)).
	self deny: (expr includes: (DateAndTime year: 2026 month: 6 day: 1)).
	self assert: (expr includes: (DateAndTime year: 2027 month: 6 day: 1))
]
