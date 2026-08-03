Class {
	#name : 'RERRuleVendorWarningsTest',
	#superclass : 'TestCase',
	#category : 'RecurringEvents-Tests',
	#package : 'RecurringEvents-Tests'
}

{ #category : 'tests' }
RERRuleVendorWarningsTest >> testByWeekNoWarnsOnAllThreeVendors [
	| tree |
	tree := REWeekInYearExpression new weeks: #(1).
	self assert: (tree rruleWarningsFor: #google) size equals: 1.
	self assert: (tree rruleWarningsFor: #apple) size equals: 1.
	self assert: (tree rruleWarningsFor: #outlook) size equals: 1
]

{ #category : 'tests' }
RERRuleVendorWarningsTest >> testByYearDayWarnsOnAllThreeVendors [
	| tree |
	tree := REDayInYearExpression new days: #(1).
	self assert: (tree rruleWarningsFor: #google) size equals: 1.
	self assert: (tree rruleWarningsFor: #apple) size equals: 1.
	self assert: (tree rruleWarningsFor: #outlook) size equals: 1.
	self assert: ((tree rruleWarningsFor: #outlook) first includesSubstring: 'no equivalent at all')
]

{ #category : 'tests' }
RERRuleVendorWarningsTest >> testMultiWeekdayBySetPosWarnsOnAllThreeVendors [
	"Last weekday of the month (BYDAY=MO,TU,WE,TH,FR;BYSETPOS=-1) is the generic multi-weekday
	case none of the three vendors can natively author, per the vendor research."
	| tree |
	tree := RETemporalExpression fromRRuleString: 'FREQ=MONTHLY;BYDAY=MO,TU,WE,TH,FR;BYSETPOS=-1' dtstart: (DateAndTime year: 2026 month: 1 day: 30).
	self assert: (tree rruleWarningsFor: #google) size equals: 1.
	self assert: (tree rruleWarningsFor: #apple) size equals: 1.
	self assert: (tree rruleWarningsFor: #outlook) size equals: 1.
	self assert: ((tree rruleWarningsFor: #outlook) first includesSubstring: 'first match')
]

{ #category : 'tests' }
RERRuleVendorWarningsTest >> testNonDefaultWkstWithMultiWeekdayIntervalWarnsGoogleAndAppleNotOutlook [
	"The classic point-6 WKST example - Outlook actually supports/requires WKST, so it
	gets no warning here, unlike Google (doesnt expose it) and Apple (read-only API)."
	| tree |
	tree := RETemporalExpression fromRRuleString: 'FREQ=WEEKLY;INTERVAL=2;BYDAY=TU,SU;WKST=SU' dtstart: (DateAndTime year: 2026 month: 8 day: 4).
	self assert: (tree rruleWarningsFor: #google) size equals: 1.
	self assert: (tree rruleWarningsFor: #apple) size equals: 1.
	self assert: (tree rruleWarningsFor: #outlook) isEmpty
]

{ #category : 'tests' }
RERRuleVendorWarningsTest >> testNonDefaultWkstWithSingleWeekdayHasNoWarnings [
	"Point 6s own finding: a single-weekday interval pattern is WKST-insensitive regardless
	of vendor, since a 7-day block always contains exactly one of any given weekday."
	| tree |
	tree := RETemporalExpression fromRRuleString: 'FREQ=WEEKLY;INTERVAL=2;BYDAY=TU;WKST=SU' dtstart: (DateAndTime year: 2026 month: 8 day: 4).
	self assert: (tree rruleWarningsFor: #google) isEmpty.
	self assert: (tree rruleWarningsFor: #apple) isEmpty.
	self assert: (tree rruleWarningsFor: #outlook) isEmpty
]

{ #category : 'tests' }
RERRuleVendorWarningsTest >> testPlainSingleWeekdayHasNoWarnings [
	| tree |
	tree := RETemporalExpression fromRRuleString: 'FREQ=WEEKLY;BYDAY=MO' dtstart: (DateAndTime year: 2026 month: 8 day: 3).
	self assert: (tree rruleWarningsFor: #google) isEmpty.
	self assert: (tree rruleWarningsFor: #apple) isEmpty.
	self assert: (tree rruleWarningsFor: #outlook) isEmpty
]

{ #category : 'tests' }
RERRuleVendorWarningsTest >> testSingleWeekdayOrdinalHasNoWarningsAnywhere [
	"Thanksgiving-style single-weekday BYSETPOS/ordinal BYDAY is natively representable by
	all three vendors (ordinary ordinal-BYDAY on Google/Apple, relativeMonthly on Outlook)."
	| tree |
	tree := RETemporalExpression fromRRuleString: 'FREQ=YEARLY;BYMONTH=11;BYDAY=4TH' dtstart: (DateAndTime year: 2026 month: 11 day: 26).
	self assert: (tree rruleWarningsFor: #google) isEmpty.
	self assert: (tree rruleWarningsFor: #apple) isEmpty.
	self assert: (tree rruleWarningsFor: #outlook) isEmpty
]
