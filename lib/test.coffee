assert = require 'assert'
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

buildTestCase = (getInstance, inCommands, outCommands) ->
  return (callback) ->
    getInstance (instance) ->
      topic =
        inSockets: {}
        outSockets: {}
        results: []
      attachSockets topic, instance, inCommands, outCommands
      subscribeOutports callback, topic, outCommands
      sendCommands topic, inCommands

class ComponentSuite
  constructor: (@subject, @customGetInstance) ->
    @spec = []
    @describe @subject

    if process.env.NOFLO_TEST_BASEDIR
      @baseDir = process.env.NOFLO_TEST_BASEDIR
    else
      @baseDir = process.cwd()
    @loader = new noflo.ComponentLoader @baseDir
    @send.suite = @
    @receive.suite = @

  describe: (text) ->
    @spec.push
      context: text
    @

  it: (text) ->
    @spec.push
      predicate: text
      inPorts: []
      outPorts: []
    @

  send:
    connect: (port) ->
      commands = @suite.ensure 'inPorts'
      commands.push
        port: port
        cmd: 'connect'
      @suite

    beginGroup: (port, group) ->
      commands = @suite.ensure 'inPorts'
      commands.push
        port: port
        cmd: 'beginGroup'
        args: [group]
      @suite

    data: (port, data) ->
      commands = @suite.ensure 'inPorts'
      commands.push
        port: port
        cmd: 'send'
        args: [data]
      @suite

    endGroup: (port) ->
      commands = @suite.ensure 'inPorts'
      commands.push
        port: port
        cmd: 'endGroup'
      @suite

    disconnect: (port) ->
      commands = @suite.ensure 'inPorts', port
      commands.push
        port: port
        cmd: 'disconnect'
      @suite

  receive:
    connect: (port) ->
      commands = @suite.ensure 'outPorts'
      commands.push
        port: port
        cmd: 'connect'
      @suite

    beginGroup: (port, group) ->
      commands = @suite.ensure 'outPorts'
      commands.push
        port: port
        cmd: 'begingroup'
        group: group
      @suite

    data: (port, data) ->
      commands = @suite.ensure 'outPorts'
      commands.push
        port: port
        cmd: 'data'
        data: data
      @suite

    endGroup: (port) ->
      commands = @suite.ensure 'outPorts'
      commands.push
        port: port
        cmd: 'endgroup'
      @suite

    disconnect: (port) ->
      commands = @suite.ensure 'outPorts'
      commands.push
        port: port
        cmd: 'disconnect'
      @suite

  ensure: (group) ->
    current = @spec[@spec.length - 1]
    current[group] = [] unless current[group]
    current[group]

  getInstance: (callback) =>
    if @customGetInstance
      callback @customGetInstance()
      return
    @loader.load @subject, (instance) ->
      callback instance

  # Export to external Mocha runner
  export: (target) ->
    return if @spec.length is 0

    spec = {}
    block = spec
    nestedBlock = block
    previousItem = null

    for item in @spec
      if item.context
        nestedBlock = block if previousItem?.context
        block = nestedBlock[item.context] = {}
      else
        inCommands = (command for command in item.inPorts)
        if previousItem.context and previousItem.inPorts?.length
          inCommands = previousItem.inPorts.concat inCommands
        testCase = buildTestCase @getInstance, inCommands, item.outPorts
        block[item.predicate] = testCase

      previousItem = item

    target.exports = spec
    @

# Main entry point into the library. Describe a component
exports.component = (name, instance) -> new ComponentSuite name, instance
