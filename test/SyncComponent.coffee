test = require '../index'
noflo = require 'noflo'

class Multiplier extends noflo.Component
  constructor: ->
    @by = 2
    @inPorts = new noflo.InPorts
      in:
        datatype: 'number'
      by:
        datatype: 'number'

    @outPorts =
      out: new noflo.Port 'number'

    @inPorts.in.on 'connect', =>
      @outPorts.out.connect()
    @inPorts.in.on 'begingroup', (group) =>
      @outPorts.out.beginGroup group
    @inPorts.in.on 'data', (data) =>
      @outPorts.out.send data * @by
    @inPorts.in.on 'endgroup', =>
      @outPorts.out.endGroup()
    @inPorts.in.on 'disconnect', =>
      @outPorts.out.disconnect()

    @inPorts.by.on 'data', (data) =>
      @by = data

suite = test.component 'Multiplier', -> new Multiplier

suite.describe 'Using the default multiplier'
suite.send.data 'in', 4
suite.it 'Should transmit 8 when receiving 4'
suite.receive.data 'out', 8

suite.describe 'Using a custom multiplier'
suite.send.data 'by', 1.5
suite.send.data 'in', 2
suite.it 'Should transmit 3 when receiving 2'
suite.receive.data 'out', 3

suite.describe 'Sending connection and disconnection events'
suite.send.connect 'in'
suite.send.disconnect 'in'
suite.it 'Should result in connect and disconnect events'
suite.receive.connect 'out'
suite.receive.disconnect 'out'

suite.describe 'Sending grouped and ungrouped data'
suite.send.beginGroup 'in', 'Foo'
suite.send.data 'in', 1
suite.send.endGroup 'in'
suite.send.data 'in', 2
suite.send.disconnect 'in'
suite.it 'Should result in similarly grouped results'
suite.receive.beginGroup 'out', 'Foo'
suite.receive.data 'out', 2
suite.receive.endGroup 'out'
suite.receive.data 'out', 4
suite.receive.disconnect 'out'

suite.export module
