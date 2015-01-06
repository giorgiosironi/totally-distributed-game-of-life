Totally distribut(able) Game Of Life
===

The [Game Of Life](http://en.wikipedia.org/wiki/Conway%27s_Game_of_Life) is a zero-player game where the initial state of an infinite plane evolves in discrete steps giving birth to interesting patterns.

I am attempting to use Elixir and the Erlang Virtual Machine to parallelize and distribute the computation, initially over multiple cores of the same machine.

**Right now** event delivery between processes is synchronous, so there is no parallelization taking place.

Next steps:
* display a generation on the terminal
* build synchronization primitives on Facade and CellShard to wait for a generaton to be completed before displaying
* parallelize tasks, how do we profile this?
* introduce a supervision tree
* attempt asynchronous delivery of events (GenEvent.notify), and see how can we introduce at-least-once delivery to deal with failures



