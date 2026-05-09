(defpackage #:dsa
  (:use #:cl)
  (:export
   ;; Dynamic Array
   #:dynamic-array
   #:da-make
   #:da-get
   #:da-set
   #:da-push
   #:da-pop
   #:da-length
   #:da-capacity
   #:da-shrink

   ;; Linked List
   #:ll-node
   #:ll-make-node
   #:linked-list
   #:ll-make
   #:ll-prepend
   #:ll-append
   #:ll-find
   #:ll-delete
   #:ll-reverse
   #:ll-length
   #:ll-to-list

   ;; Stack
   #:stack
   #:stack-make
   #:stack-push
   #:stack-pop
   #:stack-peek
   #:stack-empty-p
   #:stack-size

   ;; Queue
   #:queue
   #:queue-make
   #:queue-enqueue
   #:queue-dequeue
   #:queue-peek
   #:queue-empty-p
   #:queue-size

   ;; Deque
   #:deque
   #:deque-make
   #:deque-push-front
   #:deque-push-back
   #:deque-pop-front
   #:deque-pop-back
   #:deque-peek-front
   #:deque-peek-back
   #:deque-empty-p
   #:deque-size

   ;; Heap (Binary Heap)
   #:heap
   #:heap-make
   #:heap-insert
   #:heap-extract
   #:heap-peek
   #:heap-empty-p
   #:heap-size
   #:heapify

   ;; Priority Queue
   #:priority-queue
   #:pq-make
   #:pq-insert
   #:pq-extract-max
   #:pq-extract-min
   #:pq-peek
   #:pq-empty-p
   #:pq-size

   ;; Hash Table (open addressing, linear probing)
   #:ht
   #:ht-make
   #:ht-get
   #:ht-set
   #:ht-delete
   #:ht-contains-p
   #:ht-size
   #:ht-entries

   ;; LRU Cache
   #:lru-cache
   #:lru-make
   #:lru-get
   #:lru-put
   #:lru-size

   ;; Binary Tree
   #:bt-node
   #:bt-make-node
   #:bt-insert-left
   #:bt-insert-right
   #:bt-preorder
   #:bt-inorder
   #:bt-postorder
   #:bt-level-order
   #:bt-height
   #:bt-size

   ;; Binary Search Tree
   #:bst
   #:bst-make
   #:bst-insert
   #:bst-find
   #:bst-delete
   #:bst-min
   #:bst-max
   #:bst-successor
   #:bst-predecessor
   #:bst-to-list
   #:bst-empty-p

   ;; AVL Tree
   #:avl
   #:avl-make
   #:avl-insert
   #:avl-find
   #:avl-delete
   #:avl-to-list

   ;; Red-Black Tree
   #:rb-tree
   #:rb-make
   #:rb-insert
   #:rb-find
   #:rb-to-list

   ;; Trie
   #:trie
   #:trie-make
   #:trie-insert
   #:trie-search
   #:trie-starts-with
   #:trie-delete
   #:trie-count-words

   ;; Segment Tree
   #:segment-tree
   #:seg-make
   #:seg-query
   #:seg-update

   ;; Graph
   #:graph
   #:graph-make
   #:graph-add-vertex
   #:graph-add-edge
   #:graph-remove-edge
   #:graph-neighbors
   #:graph-vertices
   #:graph-edge-weight
   #:graph-has-vertex-p

   ;; DAG
   #:dag-topo-sort
   #:dag-has-cycle-p
   #:dag-longest-path
   #:dag-shortest-path

   ;; Union-Find (Disjoint Set)
   #:union-find
   #:uf-make
   #:uf-find
   #:uf-union
   #:uf-connected-p
   #:uf-count-sets

   ;; Bloom Filter
   #:bloom-filter
   #:bf-make
   #:bf-add
   #:bf-contains-p
   #:bf-clear

   ;; Skip List
   #:skip-list
   #:sl-make
   #:sl-insert
   #:sl-find
   #:sl-delete
   #:sl-to-list

   ;; Sorting
   #:bubble-sort
   #:selection-sort
   #:insertion-sort
   #:merge-sort
   #:quick-sort
   #:heap-sort
   #:counting-sort
   #:radix-sort

   ;; Searching
   #:binary-search
   #:linear-search
   #:jump-search
   #:interpolation-search

   ;; Graph Algorithms
   #:bfs
   #:dfs
   #:dfs-iterative
   #:dijkstra
   #:a-star
   #:bellman-ford
   #:floyd-warshall
   #:prim-mst
   #:kruskal-mst
   #:has-cycle-p
   #:connected-components
   #:topological-sort

   ;; Dynamic Programming
   #:fibonacci-dp
   #:knapsack-01
   #:longest-common-subsequence
   #:longest-increasing-subsequence
   #:edit-distance
   #:coin-change

   ;; String Algorithms
   #:kmp-search
   #:rabin-karp
   #:z-algorithm
   #:manacher
   #:lps-array
   #:lcs-string))
