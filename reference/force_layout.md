# Force-directed graph layout (Fruchterman-Reingold)

A pure-R implementation of the Fruchterman-Reingold force-directed
layout, so
[`geom_sketch_node()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_edge.md)
/
[`geom_sketch_edge()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_edge.md)
can place a network with no external graph dependency. Repulsive forces
push every node apart; attractive forces pull edge-connected nodes
together; a cooling schedule settles the system. Coordinates are
returned rescaled to roughly `[-1, 1]` on both axes.

## Usage

``` r
force_layout(edges, n_nodes = NULL, niter = 500L, seed = NULL)
```

## Arguments

- edges:

  A two-column matrix or data frame of **1-based integer node indices**,
  one row per edge (`from`, `to`). May have zero rows (an edgeless
  graph, laid out on a circle).

- n_nodes:

  Number of nodes. Defaults to the largest index in `edges` (so isolated
  high-index nodes need this set explicitly).

- niter:

  Number of iterations. Default 500.

- seed:

  Integer seed for the initial placement. `NULL` uses
  `getOption("ggsketch.seed", 1L)`. The layout is otherwise
  deterministic.

## Value

A data frame with columns `x` and `y`, one row per node in index order.

## Examples

``` r
# A small ring of five nodes
e <- cbind(1:5, c(2:5, 1))
force_layout(e, seed = 1L)
#>            x           y
#> 1  1.0000000 -0.01430852
#> 2  0.2610357  1.00000000
#> 3 -0.9765955  0.64052762
#> 4 -1.0000000 -0.59521236
#> 5  0.2210999 -1.00000000
```
