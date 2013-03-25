test = require '../index'

suite = test.component 'SplitArray'
suite.discuss 'The SplitArray component'
suite.discuss 'Should split an array into individual packets'
suite.send 'in', ['foo', 'bar']
suite.receive 'out', 'foo'
suite.receive 'out', 'bar'

suite.export module
