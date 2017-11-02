test = require '../index'
noflo = require 'noflo'

AsyncMultiplier = ->
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

    max = 1000
    min = 50
    delay = Math.floor(Math.random() * (max - min + 1)) + min
    setTimeout ->
      output.sendDone
        out: data * byNo
    , delay

suite = test.component 'AsyncMultiplier', AsyncMultiplier

suite.describe 'Using the default multiplier'
suite.it 'Should transmit 8 when receiving 4'
suite.send.data 'in', 4
suite.receive.data 'out', 8

suite.describe 'Using a custom multiplier'
suite.it 'Should transmit 3 when receiving 2'
suite.send.data 'by', 1.5
suite.send.data 'in', 2
suite.receive.data 'out', (result, chai) ->
  chai.expect(result).to.equal 3

suite.export module
