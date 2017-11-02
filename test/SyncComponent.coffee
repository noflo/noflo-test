test = require '../index'
noflo = require 'noflo'

Multiplier = ->
  c = new noflo.Component
  c.inPorts.add 'in',
    datatype: 'number'
  c.inPorts.add 'by',
    datatype: 'number'
    default: 2
  c.outPorts.add 'out',
    datatype: 'number'
  c.process (input, output) ->
    return unless input.hasData 'in'
    return if input.attached('by').length and not input.hasData 'by'
    data = input.getData 'in'
    byNo = if input.hasData('by') then input.getData('by') else 2
    output.sendDone
      out: data * byNo

suite = test.component 'Multiplier', Multiplier

suite.describe 'Using the default multiplier'
suite.send.data 'in', 4
suite.it 'Should transmit 8 when receiving 4'
suite.receive.data 'out', 8

suite.describe 'Using a custom multiplier'
suite.send.data 'by', 1.5
suite.send.data 'in', 2
suite.it 'Should transmit 3 when receiving 2'
suite.receive.data 'out', 3

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
suite.receive.disconnect 'out'
suite.receive.data 'out', 4
suite.receive.disconnect 'out'

suite.export module
