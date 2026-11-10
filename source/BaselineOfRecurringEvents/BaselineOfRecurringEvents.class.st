Class {
	#name : 'BaselineOfRecurringEvents',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfRecurringEvents',
	#package : 'BaselineOfRecurringEvents'
}

{ #category : 'baselines' }
BaselineOfRecurringEvents >> baseline: spec [
	<baseline>
	spec for: #common do: [
		self ztimestamp: spec.
		spec
			package: 'RecurringEvents-Core' with: [
				spec requires: #('ZTimestamp') ];
			package: 'RecurringEvents-Engine' with: [
				spec requires: #('RecurringEvents-Core') ];
			package: 'RecurringEvents-Tests' with: [
				spec requires: #('RecurringEvents-Engine') ]
	]
]

{ #category : 'baselines' }
BaselineOfRecurringEvents >> ztimestamp: spec [
	"the zone database, read through ZTimezone. The same spec as ApptiveScript's, so
	that an image that loads both asks for one ZTimestamp"

	spec baseline: 'ZTimestamp' with: [
		spec repository: 'github://svenvc/ZTimestamp/repository' ]
]
