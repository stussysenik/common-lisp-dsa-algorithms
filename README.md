# Common Lisp DSA Algorithms

Every data structure and algorithm implemented from scratch in ANSI Common Lisp — with a C backend via CFFI for near-native performance. No cheating — no `cl:make-hash-table`, no `cl:sort`. Just `defstruct`, `make-array`, and raw pointers.

**245 assertions. 9 test suites. 0 failures.**

```
=== RUNNING ALL DSA TESTS ===
 [PASS] Dynamic Array     [PASS] Linked List       [PASS] Stack & Queue
 [PASS] Heap & PQ         [PASS] Trees             [PASS] Graphs
 [PASS] Sorting           [PASS] Algorithms        [PASS] CFFI Bridge
=== DONE: 245 passed, 0 failed ===
```

## Quick start

```lisp
(require :asdf)
(push (truename ".") asdf:*central-registry*)
(asdf:load-system :dsa-algorithms)

;; Run everything
(dsa-tests:run-all-tests)
```

### CL-only backend (default)

```lisp
;; Default: pure CL implementations
(let ((pq (dsa:pq-make :kind :min)))
  (dsa:pq-insert pq (cons 3 'task-c))
  (dsa:pq-insert pq (cons 1 'task-a))
  (dsa:pq-extract-min pq))
;; => (1 . TASK-A)
```

### C backend via CFFI

```lisp
;; Build the C shared library first:
;;   cd src/c && make

(let ((dsa:*use-c-backend* t))
  (let ((h (dsa:heap-make)))
    (dsa:heap-insert h 5)
    (dsa:heap-insert h 3)
    (dsa:heap-extract h)))  ;; => 3 — calls C heap via CFFI
```

Requires **SBCL** and `alexandria` + `serapeum` + `cffi` via Quicklisp (`ql:quickload`).

## What's inside

### Data Structures (20)

| Structure | File | Key idea |
|---|---|---|
| Dynamic Array | `dynamic-array.lisp` | Adjustable vector with fill-pointer, amortized O(1) push/pop |
| Linked List | `linked-list.lisp` | Singly-linked, prepend/append/reverse, no tail pointer |
| Stack | `stack.lisp` | LIFO, wraps dynamic array |
| Queue | `queue.lisp` | FIFO, wraps dynamic array with head/tail pointers |
| Deque | `deque.lisp` | Double-ended, wraps dynamic array |
| Binary Heap | `heap.lisp` | Array-backed, configurable test fn (min/max), CFFI dispatch |
| Priority Queue | `priority-queue.lisp` | Wraps heap, supports min and max extraction |
| Hash Table | `hash-table.lisp` | Open addressing, linear probing, lazy init, CFFI dispatch |
| LRU Cache | `lru-cache.lisp` | Hash table + doubly-linked list, O(1) get/put, sentinel nodes |
| Binary Tree | `binary-tree.lisp` | Node + pointer structure, 4 traversals (pre/in/post/level-order) |
| BST | `binary-search-tree.lisp` | Unbalanced, with successor/predecessor/smart delete |
| AVL Tree | `avl-tree.lisp` | Self-balancing, rotation-based, height-cached, parent pointers |
| Red-Black Tree | `red-black-tree.lisp` | Color-flip rules, insert only, inorder listing |
| Trie | `trie.lisp` | Prefix tree, child hash-map per node, word count |
| Segment Tree | `segment-tree.lisp` | 1-indexed array, range sum (O(log n)), point update (O(log n)) |
| Graph | `graph.lisp` | Adjacency list (custom hash table), directed/undirected, CFFI dispatch |
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

## C Backend & CFFI Interop

Three core data structures — **heap**, **hash table**, and **graph** — have dual implementations: pure CL and C (via CFFI). Toggle between them at runtime:

```lisp
(dsa:*use-c-backend*)      ;; nil = pure CL (default)
(setf dsa:*use-c-backend* t)  ;; t = C via CFFI
```

The C implementations live in `src/c/` — 25 source files, 26 headers, a Makefile, and 23 test programs. The CFFI bridge (`src/cl/cffi/bridge.lisp`, 157 lines) handles type marshaling, pointer management, and vendor-neutral function dispatch using `cffi:foreign-funcall`.

**CFFI equivalence tests** (`tests/test-cffi-bridge.lisp`, 47 assertions) verify that the CL and C backends produce identical results for the same operations — same heap order, same hash table contents, same graph state.

```
├── src/c/
│   ├── include/    (26 headers)
│   ├── src/        (25 C implementations, 2,671 lines)
│   └── test/       (23 C test programs)
```

### Coalton (experimental)

`src/cl/coalton/coalton-structures.lisp` provides Coalton-typed `BinaryTree`, `Graph`, `coalton-quicksort`, and `coalton-mergesort` with `#+coalton` reader conditionals. Not included in the ASDF build by default.

### Multi-language scaffolding

Empty directories in `lang/` (C, Gleam, MoonBit, Nim, OCaml, Ruby, Zig) are reserved for future language ports (Phase 3).

## Why build this from scratch?

**To understand, not to use.** CL already has `make-hash-table`, `sort`, and `vector-push-extend` in the standard. This project reimplements them to expose the internals:

- **No black boxes** — Every data structure is `defstruct` + raw arrays. You see the pointer plumbing, the linear probing, the rotation logic.
- **Annotated for learning** — Every function has a docstring with complexity and a short explanation.
- **Dual backend** — The CFFI bridge demonstrates interop between CL and C, with runtime dispatch through `*use-c-backend*`.
- **Real bugs, real fixes** — The git history shows the debugging process: type errors from stale heights, cons vs scalar confusion in priority queues, SBCL's strict `dolist` on vectors.

## Architecture decisions

### Dual backend: CL + CFFI dispatch

Three data structures (heap, hash-table, graph) use a dispatch pattern:

```lisp
(defun heap-insert (heap value)
  (if *use-c-backend*
      (%heap-insert-c heap value)
      (%heap-insert-cl heap value)))
```

- **CL path** — Pure Common Lisp, defstruct-based, no FFI overhead.
- **C path** — Calls into `libdsa.so` via `cffi:foreign-funcall`, passing struct pointers and marshaling return values.
- **Equivalence** — The CFFI bridge tests verify identical semantics across backends.
- **Resource cleanup** — C-backed structs require explicit `heap-destroy`, `ht-destroy`, `graph-destroy` to free native memory.

### Hash table: lazy initialization + CFFI

The hash table uses **lazy init** — arrays are allocated on first `ht-set`, not in the constructor. This lets `graph-make`, `lru-make`, and other compound structures embed hash tables without pre-allocating storage. The `:capacity` keyword is captured and applied during init.

```
ht-make → keys=nil, vals=nil, sz=0
    ↓ first ht-set
%ht-init → allocate arrays at capacity
```

Tombstone deletion uses a gensym marker (`*ht-tombstone*`) so linear probing skips deleted slots during lookup but reuses them during insert. Resize triggers at load factor > 0.5 (grow) and < 0.125 (shrink). Both `ht-entries` and `ht-destroy` are exported for full lifecycle management.

### Heap: 0-indexed array, test-function parametrized

The binary heap avoids 1-indexing. `(floor (1- i) 2)` computes parent for any i. The `:test` function determines heap property — `#'<` for min-heap, `#'>` for max-heap. Same code, flipped comparator. `heapify` builds in O(n) via bottom-up sift-down. The C backend mirrors this logic in `src/c/src/heap.c`.

The priority queue wraps the heap and adds `:kind :min`/`:max` to select the comparator. Items stored as `(priority . value)` conses — the comparator extracts the car transparently, so both `(pq-insert pq 42)` (for standalone use) and `(pq-insert pq (cons 0 start))` (for Dijkstra) work correctly.

### Graph: custom hash table adjacency + CFFI

The graph uses the project's own hash table (`ht`) for the adjacency list, not Common Lisp's built-in `make-hash-table`. Each vertex maps to a nested hash table of `(to . edge)`. This creates a dependency chain:

```
graph → ht → dynamic-array
```

The `dag` module shares the graph definition via the `graph.lisp` struct — `dag-topo-sort`, `dag-has-cycle-p`, `dag-longest-path`, and `dag-shortest-path` all operate on the same graph struct. Both CL and C backends support `graph-add-vertex`, `graph-add-edge`, `graph-remove-edge`, `graph-neighbors`, `graph-vertices`, `graph-edge-weight`, `graph-has-vertex-p`, and `graph-destroy`.

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
;; All 245 assertions across 9 suites:
(dsa-tests:run-all-tests)

;; Or individual suites:
(dsa-tests:test-dynamic-array)
(dsa-tests:test-linked-list)
(dsa-tests:test-stack-queue)
(dsa-tests:test-heap)
(dsa-tests:test-trees)
(dsa-tests:test-graph)
(dsa-tests:test-sorting)
(dsa-tests:test-algorithms)
(dsa-tests:test-cffi-bridge)

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
  cl/
    package.lisp                  240 exported symbols
    cffi/
      bridge.lisp                 CFFI dispatch (157 lines)
    coalton/
      coalton-structures.lisp     Coalton types (88 lines)
    data-structures/
      dynamic-array.lisp          Adjustable vector (47 lines)
      linked-list.lisp            Singly-linked (81 lines)
      stack.lisp                  LIFO (29 lines)
      queue.lisp                  FIFO (41 lines)
      deque.lisp                  Double-ended (77 lines)
      heap.lisp                   Binary heap + CFFI (153 lines)
      priority-queue.lisp         Min/max PQ (34 lines)
      hash-table.lisp             Open addressing + CFFI (177 lines)
      lru-cache.lisp              O(1) eviction (72 lines)
      binary-tree.lisp            Traversals (66 lines)
      binary-search-tree.lisp     Unbalanced BST (129 lines)
      avl-tree.lisp               Rotations (146 lines)
      red-black-tree.lisp         Color flips (148 lines)
      trie.lisp                   Prefix tree (61 lines)
      segment-tree.lisp           Range sums (62 lines)
      graph.lisp                  Adjacency list + CFFI (158 lines)
      dag.lisp                    Topo sort + paths (76 lines)
      union-find.lisp             Disjoint set (49 lines)
      bloom-filter.lisp           Bit vector (37 lines)
      skip-list.lisp              Probabilistic (91 lines)
    algorithms/
      sorting.lisp                8 sorts (166 lines)
      searching.lisp              4 searches (90 lines)
      graph-algorithms.lisp       12 algos (270 lines)
      dynamic-programming.lisp    6 DP problems (116 lines)
      string-algorithms.lisp      6 string algos (134 lines)
  c/
    include/                      26 header files
    src/                          25 C implementations (2,671 lines)
    test/                         23 C test programs
    Makefile
tests/
  package.lisp                    Test framework (77 lines)
  test-dynamic-array.lisp
  test-linked-list.lisp
  test-stack-queue.lisp
  test-heap.lisp
  test-trees.lisp
  test-graph.lisp
  test-sorting.lisp
  test-algorithms.lisp
  test-cffi-bridge.lisp           CFFI equivalence (189 lines)
```

## License

MIT
