"
A `GtLFunctionTool` whose result reaches the MCP client as plain text: the string its block answers, as is.

A plain `GtLFunctionTool` answers an MCP client a JSON description of the result object (its class, print string, views...), which buries the actual answer. All `ClaudeMcpServer` tools are of this kind.
"
Class {
	#name : 'ClaudeMcpTextTool',
	#superclass : 'GtLFunctionTool',
	#category : 'Claude-MCP',
	#package : 'Claude-MCP'
}

{ #category : 'private' }
ClaudeMcpTextTool >> resultObjectFromDomainObject: aDomainObject [
	"GtLFunctionTool answers its block's value wrapped in a GtLObjectValueResult"
	^ ClaudeMcpTextResult new
		model: ((aDomainObject isKindOf: GtLObjectValueResult)
			ifTrue: [ aDomainObject object ]
			ifFalse: [ aDomainObject ]);
		yourself
]
