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
		spec
			package: 'RecurringEvents-Core';
			package: 'RecurringEvents-Engine' with: [
				spec requires: #('RecurringEvents-Core') ];
			package: 'RecurringEvents-Tests' with: [
				spec requires: #('RecurringEvents-Engine') ]
	]
]
