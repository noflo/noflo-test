test = require '../index'
noflo = require 'noflo'

class AsyncMultiplier extends noflo.AsyncComponent
  constructor: ->
    @by = 2
    @inPorts =
      in: new noflo.Port 'number'
      by: new noflo.Port 'number'

    @outPorts =
      out: new noflo.Port 'number'

    @inPorts.by.on 'data', (data) =>
      @by = data

    super 'in'

  getRandomInt: (min, max) ->
    Math.floor(Math.random() * (max - min + 1)) + min

  doAsync: (number, callback) ->
    timeOut = @getRandomInt 50, 1000
    setTimeout =>
      @outPorts.out.send number * @by
      @outPorts.out.disconnect()
      callback null
    , timeOut

suite = test.component 'AsyncMultiplier', -> new AsyncMultiplier
suite.discuss 'Using the default multiplier'
suite.discuss 'Should transmit 8 when receiving 4'
suite.send.data 'in', 4
suite.receive.data 'out', 8
suite.next()
suite.discuss 'Using a custom multiplier'
suite.discuss 'Should transmit 3 when receiving 2'
suite.send.data 'by', 1.5
suite.send.data 'in', 2
suite.receive.data 'out', 3

suite.export module
