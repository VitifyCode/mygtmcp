"
The result of a `ClaudeMcpTextTool`: serializes for an MCP response as a single text content item holding the result string.
"
Class {
	#name : 'ClaudeMcpTextResult',
	#superclass : 'GtLWrappedObjectModel',
	#category : 'Claude-MCP',
	#package : 'Claude-MCP'
}

{ #category : 'serialization' }
ClaudeMcpTextResult >> serializeForMCPResponseOutput [
	^ { { 'type' -> 'text'.
		'text' -> (model isString ifTrue: [ model ] ifFalse: [ model printString ]) } asDictionary }
]
