Class {
	#name : 'ClaudeMcpServerExamples',
	#superclass : 'Object',
	#category : 'Claude-MCP',
	#package : 'Claude-MCP'
}

{ #category : 'examples' }
ClaudeMcpServerExamples >> exampleEnsureRunningIsIdempotent [
	"ensureRunning on an already-running server should not restart it"
	<gtExample>
	| mcpServer |
	mcpServer := ClaudeMcpServer new.
	mcpServer port: 0.
	mcpServer start.
	[	| portBefore |
		portBefore := mcpServer server port.
		mcpServer ensureRunning.
		self assert: mcpServer isRunning.
		self assert: mcpServer server port equals: portBefore
	] ensure: [ mcpServer stop ].
	^ mcpServer
]

{ #category : 'examples' }
ClaudeMcpServerExamples >> exampleEnsureRunningStartsStoppedServer [
	"ensureRunning should start a server that is not running"
	<gtExample>
	| mcpServer |
	mcpServer := self exampleIsNotRunningWhenNew.
	mcpServer port: 0.
	mcpServer ensureRunning.
	[ self assert: mcpServer isRunning ] ensure: [ mcpServer stop ].
	^ mcpServer
]

{ #category : 'examples' }
ClaudeMcpServerExamples >> exampleIsNotRunningWhenNew [
	"A fresh ClaudeMcpServer should not be running"
	<gtExample>
	| mcpServer |
	mcpServer := ClaudeMcpServer new.
	self assert: mcpServer isRunning equals: false.
	^ mcpServer
]

{ #category : 'examples' }
ClaudeMcpServerExamples >> exampleIsRunningWhenStarted [
	"A started ClaudeMcpServer should report isRunning true"
	<gtExample>
	| mcpServer |
	mcpServer := ClaudeMcpServer new.
	mcpServer port: 0.
	mcpServer start.
	[ self assert: mcpServer isRunning ] ensure: [ mcpServer stop ].
	^ mcpServer
]
