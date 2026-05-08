# Common Lisp DSA Algorithms

Every data structure and algorithm implemented from scratch in ANSI Common Lisp. No cheating — no `cl:make-hash-table`, no `cl:sort`. Just `defstruct`, `make-array`, and raw pointers.

**160 assertions. 8 test suites. 0 failures.**

```
=== RUNNING ALL DSA TESTS ===
 [PASS] Dynamic Array     [PASS] Linked List       [PASS] Stack & Queue
 [PASS] Heap & PQ         [PASS] Trees             [PASS] Graphs
 [PASS] Sorting           [PASS] Algorithms
=== DONE: 160 passed, 0 failed ===
```

## Quick start

```lisp
(require :asdf)
(push (truename ".") asdf:*central-registry*)
(asdf:load-system :dsa-algorithms)

;; Run everything
(dsa-tests:run-all-tests)
```

Requires **SBCL** and `alexandria` + `serapeum` via Quicklisp (`ql:quickload`).

## What's inside

### Data Structures (20)

| Structure | File | Key idea |
|---|---|---|
| Dynamic Array | `dynamic-array.lisp` | Adjustable vector with fill-pointer, amortized O(1) push/pop |
| Linked List | `linked-list.lisp` | Singly-linked, prepend/append/reverse, no tail pointer |
| Stack | `stack.lisp` | LIFO, wraps dynamic array |
| Queue | `queue.lisp` | FIFO, wraps dynamic array with head/tail pointers |
| Deque | `deque.lisp` | Double-ended, wraps dynamic array |
| Binary Heap | `heap.lisp` | Array-backed, configurable test fn (min/max), 0-indexed |
| Priority Queue | `priority-queue.lisp` | Wraps heap, supports min and max extraction |
| Hash Table | `hash-table.lisp` | Open addressing, linear probing, **lazy initialization**, tombstone deletion |
| LRU Cache | `lru-cache.lisp` | Hash table + doubly-linked list, O(1) get/put, sentinel nodes |
| Binary Tree | `binary-tree.lisp` | Node + pointer structure, 4 traversals (pre/in/post/level-order) |
| BST | `binary-search-tree.lisp` | Unbalanced, with successor/predecessor/smart delete |
| AVL Tree | `avl-tree.lisp` | Self-balancing, rotation-based, height-cached, parent pointers |
| Red-Black Tree | `red-black-tree.lisp` | Color-flip rules, insert only, inorder listing |
| Trie | `trie.lisp` | Prefix tree, child hash-map per node, word count |
| Segment Tree | `segment-tree.lisp` | 1-indexed array, range sum (O(log n)), point update (O(log n)) |
| Graph | `graph.lisp` | Adjacency list (custom hash table), directed/undirected, weighted edges |
| DAG | `dag.lisp` | Topological sort (Kahn), cycle detection, longest/shortest path |
| Union-Find | `union-find.lisp` | Rank + path compression, O(α(n)) amortized |
| Bloom Filter | `bloom-filter.lisp` | Bit vector, k hash functions, optimal m/k from n and p |
| Skip List | `skip-list.lisp` | Probabilistic levels, coin-flip promotion, simpler than balanced trees |

### Algorithm Modules (5)

**Sorting** (8 algorithms, `sorting.lisp`):
`bubble-sort` `selection-sort` `insertion-sort` `merge-sort` `quick-sort` `heap-sort` `counting-sort` `radix-sort`

**Searching** (4 algorithms, `searching.lisp`):
`binary-search` `linear-search` `jump-search` `interpolation-search`

**Graph Algorithms** (12 algorithms, `graph-algorithms.lisp`):
`bfs` `dfs` `dfs-iterative` `dijkstra` `a-star` `bellman-ford` `floyd-warshall` `prim-mst` `kruskal-mst` `has-cycle-p` `connected-components` `topological-sort`

**Dynamic Programming** (6 problems, `dynamic-programming.lisp`):
`fibonacci-dp` `knapsack-01` `longest-common-subsequence` `longest-increasing-subsequence` `edit-distance` `coin-change`

**String Algorithms** (6 algorithms, `string-algorithms.lisp`):
`kmp-search` `rabin-karp` `z-algorithm` `manacher` `lps-array` `lcs-string`

## Why build this from scratch?

**To understand, not to use.** CL already has `make-hash-table`, `sort`, and `vector-push-extend` in the standard. This project reimplements them to expose the internals:

- **No black boxes** — Every data structure is `defstruct` + raw arrays. You see the pointer plumbing, the linear probing, the rotation logic.
- **Annotated for learning** — Every function has a docstring with complexity and a short explanation.
- **Real bugs, real fixes** — The git history shows the debugging process: type errors from stale heights, cons vs scalar confusion in priority queues, SBCL's strict `dolist` on vectors.

## Architecture decisions

### Hash table: lazy initialization

The hash table uses **lazy init** — arrays are allocated on first `ht-set`, not in the constructor. This lets `graph-make`, `lru-make`, and other compound structures embed hash tables without pre-allocating storage. The `:capacity` keyword is captured and applied during init.

```
ht-make → keys=nil, vals=nil, sz=0
    ↓ first ht-set
%ht-init → allocate arrays at capacity
```

Tombstone deletion uses a gensym marker (`*ht-tombstone*`) so linear probing skips deleted slots during lookup but reuses them during insert. Resize triggers at load factor > 0.5 (grow) and < 0.125 (shrink).

### Heap: 0-indexed array, test-function parametrized

The binary heap avoids 1-indexing. `(floor (1- i) 2)` computes parent for any i. The `:test` function determines heap property — `#'<` for min-heap, `#'>` for max-heap. Same code, flipped comparator. `heapify` builds in O(n) via bottom-up sift-down.

The priority queue wraps the heap and adds `:kind :min`/`:max` to select the comparator. Items stored as `(priority . value)` conses — the comparator extracts the car transparently, so both `(pq-insert pq 42)` (for standalone use) and `(pq-insert pq (cons 0 start))` (for Dijkstra) work correctly.

### Graph: custom hash table adjacency

The graph uses the project's own hash table (`ht`) for the adjacency list, not Common Lisp's built-in `make-hash-table`. Each vertex maps to a nested hash table of `(to . edge)`. This creates a dependency chain:

```
graph → ht → dynamic-array
```

The `dag` module shares the graph definition via the `graph.lisp` struct — `dag-topo-sort`, `dag-has-cycle-p`, `dag-longest-path`, and `dag-shortest-path` all operate on the same graph struct.

### LRU Cache: sentinel nodes

The doubly-linked list uses head and tail sentinels to eliminate null checks. `%lru-remove` consistently unlinks any node because prev/next are always valid. The hash table stores pointers to list nodes — O(1) lookup, O(1) move-to-front, O(1) eviction.

### AVL Tree: height tracking + parent pointers

Each node stores its height and parent in addition to left/right children. Heights are recalculated bottom-up after every insert/delete. The balance check is `(- height-left height-right)` and rotations update parent pointers on all affected nodes. The `return-from` in `%avl-insert-node` (when `node` is nil) was the critical bug — without it, execution fell through to `%avl-update-height` on nil.

### Priority Queue comparator: cons-aware lambda

The comparator wraps car extraction with a type guard:
```lisp
(lambda (a b) (< (if (consp a) (car a) a)
                 (if (consp b) (car b) b)))
```

This lets `pq-insert` accept both plain values (for standalone tests) and `(priority . value)` conses (for Dijkstra, Prim's). Without this, `(< '(1 . 2) '(0 . 0))` triggers a `REAL` type error in SBCL.

## Running tests

```lisp
;; All 160 assertions across 8 suites:
(dsa-tests:run-all-tests)

;; Or individual suites:
(dsa-tests:test-dynamic-array)
(dsa-tests:test-heap)
(dsa-tests:test-trees)
(dsa-tests:test-graph)
(dsa-tests:test-sorting)
(dsa-tests:test-algorithms)

;; Raw REPL exploration:
(let ((pq (dsa:pq-make :kind :min)))
  (dsa:pq-insert pq (cons 3 'task-c))
  (dsa:pq-insert pq (cons 1 'task-a))
  (dsa:pq-insert pq (cons 2 'task-b))
  (loop while (not (dsa:pq-empty-p pq))
        collect (dsa:pq-extract-min pq)))
;; => ((1 . TASK-A) (2 . TASK-B) (3 . TASK-C))
```

## File map

```
src/
  package.lisp                 234 exported symbols
  data-structures/
    dynamic-array.lisp         Adjustable vector (47 lines)
    linked-list.lisp           Singly-linked (81 lines)
    stack.lisp                 LIFO (29 lines)
    queue.lisp                 FIFO (41 lines)
    deque.lisp                 Double-ended (77 lines)
    heap.lisp                  Binary heap (90 lines)
    priority-queue.lisp        Min/max PQ (34 lines)
    hash-table.lisp            Open addressing (90 lines)
    lru-cache.lisp             O(1) eviction (72 lines)
    binary-tree.lisp           Traversals (66 lines)
    binary-search-tree.lisp    Unbalanced BST (129 lines)
    avl-tree.lisp              Rotations (137 lines)
    red-black-tree.lisp        Color flips (148 lines)
    trie.lisp                  Prefix tree (61 lines)
    segment-tree.lisp          Range sums (62 lines)
    graph.lisp                 Adjacency list (69 lines)
    dag.lisp                   Topo sort + paths (76 lines)
    union-find.lisp            Disjoint set (49 lines)
    bloom-filter.lisp          Bit vector (37 lines)
    skip-list.lisp             Probabilistic (91 lines)
  algorithms/
    sorting.lisp               8 sorts (166 lines)
    searching.lisp             4 searches (90 lines)
    graph-algorithms.lisp      12 algos (270 lines)
    dynamic-programming.lisp   6 DP problems (116 lines)
    string-algorithms.lisp     6 string algos (134 lines)
```

## License

MIT
