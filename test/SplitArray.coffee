test = require '../index'

test.component('SplitArray').
  discuss('When receiving an array with two cells').
    send('in', ['foo', 'bar']).
    discuss('Each cell should be sent out as a separate package').
      receive('out', 'foo').
      receive('out', 'bar').
  next().
  discuss('When receiving an array with three numeric cells').
    send('in', [3, 2, 1]).
    discuss('Each cell should be sent out as a separate package').
      receive('out', 3).
      receive('out', 2).
      receive('out', 1).
export module
