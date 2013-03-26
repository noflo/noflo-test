assert = require 'assert'
vows = require 'vows'
noflo = require 'noflo'
{_} = require 'underscore'

attachSockets = (topic, instance, inCommands, outCommands) ->
  for command in inCommands
    continue if topic.inSockets[command.port]
    topic.inSockets[command.port] = noflo.internalSocket.createSocket()
    instance.inPorts[command.port].attach topic.inSockets[command.port]
  for command in outCommands
    continue if topic.outSockets[command.port]
    topic.outSockets[command.port] = noflo.internalSocket.createSocket()
    instance.outPorts[command.port].attach topic.outSockets[command.port]

subscribeOutports = (callback, topic, outCommands) ->
  done = _.after outCommands.length, ->
    callback null, topic

  listened = {}
  outCommands.forEach (command) ->
    listened[command.port] = {} unless listened[command.port]
    return if listened[command.port][command.cmd]
    port = topic.outSockets[command.port]
    port.on command.cmd, (value) ->
      topic.results.push
        port: command.port
        cmd: command.cmd
        data: value
      done()
    listened[command.port][command.cmd] = true

sendCommands = (topic, inCommands) ->
  inCommands.forEach (command) ->
    func = topic.inSockets[command.port][command.cmd]
    func.apply topic.inSockets[command.port], command.args

buildTopic = (getInstance, inCommands, outCommands) ->
  return ->
    callback = @callback
    getInstance (instance) ->
      topic =
        inSockets: {}
        outSockets: {}
        results: []
      attachSockets topic, instance, inCommands, outCommands
      subscribeOutports callback, topic, outCommands
      sendCommands topic, inCommands

buildTests = (outCommands) ->
  return (err, topic) ->
    throw err if err
    throw new Error "no results" unless topic.results
    outCommands.forEach (command) ->
      received = topic.results.shift()
      assert.equal received.port, command.port
      assert.equal received.cmd, command.cmd
      if command.data
        assert.equal received.data, command.data

class ComponentSuite
  constructor: (@name, @customGetInstance) ->
    @suite = vows.describe @name
    @discussion = []
    @batches = []
    @loader = new noflo.ComponentLoader process.cwd()
    @loader.listComponents ->

  discuss: (text) ->
    @discussion.push
      context: text
      inPorts: []
      outPorts: []
    @

  undiscuss: ->
    @discussion.pop()
    @

  connect: (port) ->
    commands = @ensure 'inPorts'
    commands.push
      port: port
      cmd: 'connect'
    @

  beginGroup: (port, group) ->
    commands = @ensure 'inPorts'
    commands.push
      port: port
      cmd: 'beginGroup'
      args: [group]
    @

  send: (port, data) ->
    commands = @ensure 'inPorts'
    commands.push
      port: port
      cmd: 'send'
      args: [data]
    @

  endGroup: (port) ->
    commands = @ensure 'inPorts'
    commands.push
      port: port
      cmd: 'endGroup'
    @

  disconnect: (port) ->
    commands = @ensure 'inPorts', port
    commands.push
      port: port
      cmd: 'disconnect'
    @

  receive: (port, data, group) ->
    commands = @ensure 'outPorts'
    commands.push
      port: port
      cmd: 'data'
      data: data
    @

  ensure: (group) ->
    current = @discussion[@discussion.length - 1]
    current[group] = [] unless current[group]
    current[group]

  getInstance: (callback) =>
    if @customGetInstance
      callback @customGetInstance()
      return
    @loader.load @name, callback

  next: ->
    return if @discussion.length is 0
    batch = {}
    context = batch
    inCommands = []
    @discussion.forEach (discussion) =>
      for command in discussion.inPorts
        inCommands.push command

      if discussion.outPorts.length is 0
        # No expected returns, just keep building context
        context[discussion.context] = {}
        context = context[discussion.context]
        return

      # We have stuff to run
      context.topic = buildTopic @getInstance, inCommands, discussion.outPorts
      context[discussion.context] = buildTests discussion.outPorts

    @batches.push batch
    @suite.addBatch batch
    @discussion = []
    @

  # Export to external Vows runner
  export: (target) ->
    @next()
    @suite.export target
    @

  run: (options, callback) ->
    @next()
    unless callback
      callback = options
      options = {}
    @suite.run options, callback
    @

# Main entry point into the library. Describe a component
exports.component = (name, instance) -> new ComponentSuite name, instance
