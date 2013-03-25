test = require '../index'

suite = test.component 'SplitArray'
suite.discuss 'When receiving an array with two cells'
suite.send 'in', ['foo', 'bar']
suite.discuss 'Each cell should be sent out as a separate package'
suite.receive 'out', 'foo'
suite.receive 'out', 'bar'

suite.export module
