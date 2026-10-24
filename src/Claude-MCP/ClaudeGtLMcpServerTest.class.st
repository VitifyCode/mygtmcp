Class {
	#name : 'ClaudeGtLMcpServerTest',
	#superclass : 'TestCase',
	#instVars : [
		'server',
		'client',
		'port'
	],
	#category : 'Claude-MCP',
	#package : 'Claude-MCP'
}

{ #category : 'asserting' }
ClaudeGtLMcpServerTest >> assertRespondsWithin2Seconds: aBlock status: aStatusCode [
	| millis |
	millis := Time millisecondsToRun: aBlock.
	self assert: millis < 2000.
	self assert: client response statusLine code equals: aStatusCode
]

{ #category : 'running' }
ClaudeGtLMcpServerTest >> setUp [
	super setUp.
	port := 3177.
	"Synchronous: TestCase terminates the processes a test forks, which would kill
	 the async future workers GT starts on the first request and hang later tests."
	server := ClaudeGtLMcpServer new port: port; beSynchronous; yourself.
	server start.
	client := ZnClient new
		timeout: 2;
		url: 'http://localhost:', port printString, '/';
		yourself
]

{ #category : 'running' }
ClaudeGtLMcpServerTest >> tearDown [
	client ifNotNil: [ client close ].
	server ifNotNil: [ server stop ].
	super tearDown
]

{ #category : 'tests' }
ClaudeGtLMcpServerTest >> testGetAnswers405AndCloses [
	self assertRespondsWithin2Seconds: [ client get ] status: 405
]

{ #category : 'tests' }
ClaudeGtLMcpServerTest >> testHeadAnswers405AndCloses [
	self assertRespondsWithin2Seconds: [ client head ] status: 405
]

{ #category : 'tests' }
ClaudeGtLMcpServerTest >> testInitializeStillAnswersJsonBody [
	client entity: (ZnEntity
		with: '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"t","version":"0"}}}'
		type: ZnMimeType applicationJson).
	client post.
	self assert: client response statusLine code equals: 200.
	self assert: (client response contents includesSubstring: 'serverInfo')
]

{ #category : 'tests' }
ClaudeGtLMcpServerTest >> testNotificationAnswers202AndCloses [
	client entity: (ZnEntity
		with: '{"jsonrpc":"2.0","method":"notifications/initialized"}'
		type: ZnMimeType applicationJson).
	self assertRespondsWithin2Seconds: [ client post ] status: 202.
	self assert: (client response headers at: 'Content-Length' ifAbsent: [ nil ]) equals: '0'
]

{ #category : 'private' }
ClaudeGtLMcpServerTest >> callTool: aName arguments: aJsonObjectString [
	server addTool: (ClaudeMcpTextTool new
		name: 'echo';
		parameters: { 'text' };
		description: 'Answers its text';
		block: [ :call | call arguments at: 'text' ]).
	server addTool: (ClaudeMcpTextTool new
		name: 'fail';
		parameters: { 'text' };
		description: 'Always fails';
		block: [ :call | self error: 'boom ', (call arguments at: 'text') ]).
	client entity: (ZnEntity
		with: '{"jsonrpc":"2.0","id":7,"method":"tools/call","params":{"name":"', aName, '","arguments":', aJsonObjectString, '}}'
		type: ZnMimeType applicationJson).
	client post.
	self assert: client response statusLine code equals: 200.
	^ (STONJSON fromString: client response contents) at: 'result'
]

{ #category : 'tests' }
ClaudeGtLMcpServerTest >> testFailingToolAnswersAnIsErrorResult [
	| result |
	result := self callTool: 'fail' arguments: '{"text":"now"}'.
	self assert: (result at: 'isError').
	self assert: (((result at: 'content') first at: 'text') includesSubstring: 'boom now').
	self assert: server errorsSnapshot size equals: 1.
	server clearErrors.
	self assert: server errorsSnapshot isEmpty
]

{ #category : 'tests' }
ClaudeGtLMcpServerTest >> testToolCallAnswersItsResultAndIsRecordedInTheHistory [
	| result |
	result := self callTool: 'echo' arguments: '{"text":"hello"}'.
	self deny: (result at: 'isError').
	self assert: ((result at: 'content') first at: 'text') equals: 'hello'.
	self assert: server historySnapshot size equals: 1.
	self assert: server historySnapshot first toolCall name equals: 'echo'
]
