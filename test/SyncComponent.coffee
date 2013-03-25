test = require '../index'
noflo = require 'noflo'

class Multiplier extends noflo.Component
  constructor: ->
    @by = 2
    @inPorts =
      in: new noflo.Port 'number'
      by: new noflo.Port 'number'

    @outPorts =
      out: new noflo.Port 'number'

    @inPorts.in.on 'data', (data) =>
      @outPorts.out.send data * @by
      @outPorts.out.disconnect()

    @inPorts.by.on 'data', (data) =>
      @by = data

suite = test.component 'Multiplier', -> new Multiplier
suite.discuss 'Using the default multiplier'
suite.discuss 'Should transmit 8 when receiving 4'
suite.send 'in', 4
suite.receive 'out', 8
suite.next()
suite.discuss 'Using a custom multiplier'
suite.discuss 'Should transmit 3 when receiving 2'
suite.send 'by', 1.5
suite.send 'in', 2
suite.receive 'out', 3

suite.export module
