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
			package: 'RecurringEvents-Common';
			package: 'RecurringEvents-Core' with: [
				spec requires: #('RecurringEvents-Common') ];
			package: 'RecurringEvents-Tests' with: [
				spec requires: #('RecurringEvents-Core') ]
	]
]
