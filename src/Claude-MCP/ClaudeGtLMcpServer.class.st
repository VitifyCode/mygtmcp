"
The MCP server behind `ClaudeMcpServer`.

A `GtLMcpServer` whose tools report their failures the MCP way: a tool that raises an error answers a `tools/call` result with `isError: true` and the error text, so the client (and the LLM driving it) sees what went wrong. Plain `GtLMcpServer` answers such a call with an HTTP 400 instead.

In debug mode (`setDebug`) the error is passed on so it can be debugged in the image.
"
Class {
	#name : 'ClaudeGtLMcpServer',
	#superclass : 'GtLMcpServer',
	#category : 'Claude-MCP',
	#package : 'Claude-MCP'
}

{ #category : 'accessing' }
ClaudeGtLMcpServer >> clearErrors [
	errors lock: [ :aCollection | aCollection removeAll ]
]

{ #category : 'handlers' }
ClaudeGtLMcpServer >> handleToolsCall: aJsonRpc [
	^ [ super handleToolsCall: aJsonRpc ]
		on: Error
		do: [ :anError |
			self isDebug ifTrue: [ anError pass ].
			self privateAddErrorRecord: (GtLMcpServerRequestHandlerErrorRecord
				forException: anError
				jsonRpc: aJsonRpc
				request: nil
				response: nil).
			{ 'content' -> { { 'type' -> 'text'.
						'text' -> ('Error: ', anError class name, ' - ', anError messageText asString) } asDictionary } asArray.
				'isError' -> true } asDictionary ]
]
