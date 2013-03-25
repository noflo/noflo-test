test = require '../index'

test.component('SplitArray').
  discuss('When receiving an array with two cells').
    send('in', ['foo', 'bar']).
    discuss('Each cell should be sent out as a separate package').
      receive('out', 'foo').
      receive('out', 'bar').
export module
