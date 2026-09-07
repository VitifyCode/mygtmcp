Class {
	#name : 'GtMcpServerTest',
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
GtMcpServerTest >> assertRespondsWithin2SecondsAndClosed: aBlock status: aStatusCode [
	| millis response |
	millis := Time millisecondsToRun: aBlock.
	self assert: millis < 2000.
	response := client response.
	self assert: response statusLine code equals: aStatusCode.
	self assert: (response headers at: 'Content-Length' ifAbsent: [ nil ]) equals: '0'
]

{ #category : 'running' }
GtMcpServerTest >> setUp [
	super setUp.
	port := 3177.
	server := GtMcpServer new port: port; yourself.
	server start.
	client := ZnClient new
		timeout: 2;
		url: 'http://localhost:', port printString, '/';
		yourself
]

{ #category : 'running' }
GtMcpServerTest >> tearDown [
	client ifNotNil: [ client close ].
	server ifNotNil: [ server stop ].
	super tearDown
]

{ #category : 'tests' }
GtMcpServerTest >> testGetAnswers405AndCloses [
	self assertRespondsWithin2SecondsAndClosed: [ client get ] status: 405
]

{ #category : 'tests' }
GtMcpServerTest >> testHeadAnswers405AndCloses [
	self assertRespondsWithin2SecondsAndClosed: [ client head ] status: 405
]

{ #category : 'tests' }
GtMcpServerTest >> testInitializeStillAnswersJsonBody [
	client entity: (ZnEntity
		with: '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"t","version":"0"}}}'
		type: ZnMimeType applicationJson).
	client post.
	self assert: client response statusLine code equals: 200.
	self assert: (client response contents includesSubstring: 'serverInfo')
]

{ #category : 'tests' }
GtMcpServerTest >> testNotificationAnswers202AndCloses [
	client entity: (ZnEntity
		with: '{"jsonrpc":"2.0","method":"notifications/initialized"}'
		type: ZnMimeType applicationJson).
	self assertRespondsWithin2SecondsAndClosed: [ client post ] status: 202
]
