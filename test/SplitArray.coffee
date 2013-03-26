test = require '../index'

test.component('SplitArray').
  discuss('When receiving an array with two cells').
    send.data('in', ['foo', 'bar']).
    discuss('Each cell should be sent out as a separate package').
      receive.data('out', 'foo').
      receive.data('out', 'bar').
  next().
  discuss('When receiving an array with three numeric cells').
    send.data('in', [3, 2, 1]).
    discuss('Each cell should be sent out as a separate package').
      receive.data('out', 3).
      receive.data('out', 2).
      receive.data('out', 1).
export module
