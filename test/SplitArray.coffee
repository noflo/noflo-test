test = require '../index'

test.component('SplitArray').
  describe('When receiving an array with two cells').
    send.data('in', ['foo', 'bar']).
    it('Should send each cell out as a separate package').
      receive.data('out', 'foo').
      receive.data('out', 'bar').
  describe('When receiving an array with three numeric cells').
    send.data('in', [3, 2, 1]).
    it('Should send each cell out as a separate package').
      receive.data('out', 3).
      receive.data('out', 2).
      receive.data('out', 1).
export module
