Totally distribut(able) Game Of Life
===

The [Game Of Life](http://en.wikipedia.org/wiki/Conway%27s_Game_of_Life) is a zero-player game where the initial state of an infinite plane evolves in discrete steps giving birth to interesting patterns.

## How to run

    iex -S mix run scripts/bar.exs
    iex -S mix run scripts/random.exs

Stop the evolution with `Ctrl-C` followed by `a`.

## Design

I am attempting to use Elixir and the Erlang Virtual Machine to parallelize and distribute the computation, initially over multiple cores of the same machine:

![Diagram of shards](https://raw.githubusercontent.com/giorgiosironi/totally-distributed-game-of-life/master/diagram.jpg)

This diagram assumes there are 4 shards. Each generation is then built by 4 CellShards, adding 4 NeighborhoodShards spawned during evolution. Each Shard correspond to 1/4th of the total columns for now, but depending on both column and row would be best.

Every CellShard generates an event to be consumed by the Neighborhood shards:

    {:neighborhood_needed_number, destination_shard, number}
    
Each CellShardtells its cells to evolve, and they generate each 9 events (in total `9*number`):

    {:neighborhood_needed, destination_shard, position, original_cell}

telling each of them how many messages they expect to receive from the Cells of the previous generation.

Once each NeighoborhoodShard of generation N has received all messages, it can begin calculating generation N+1, and a new CellShard for generation N+1 is created for each of them.

To complete evolution, each NeighborhoodShard emits one event:

    {:cells_considered, destination_shard, number}
    
and `number` events:

    {:cell, destination_shard, position, :alive|:dead}

`destination_shard` here is really unnecessary as each NeighborhoodShard corresponds to a single new CellShard.

## Implementation

All events and wiring is already in place and working, as shown in `test/gol_test.exs`.

All GenEvent delivery between processes is asynchronous through notify/2, so work is parallelized over 4 beam.smp OS processes. Since all processes are linked, any failure will cause the termination of the simulation for now (which is at least better than silently ignoring them or lose events.)

Next steps:
* garbage collection of old generations processes
* introduce a supervision tree
* shards should act both on rows and columns, not just on one dimension



