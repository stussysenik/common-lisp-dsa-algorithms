(in-package #:dsa-tests)

(defun test-graph ()
  (format t "~%=== Graph Tests ===~%")

  ;; Graph basics
  (let ((g (graph-make)))
    (graph-add-vertex g 'a)
    (graph-add-vertex g 'b)
    (graph-add-edge g 'a 'b 5)
    (assert-true (graph-has-vertex-p g 'a) "Has vertex: ")
    (assert-equal 5 (graph-edge-weight g 'a 'b) "Edge weight: ")
    (assert-equal 1 (length (graph-neighbors g 'a)) "Neighbors count: ")
    (assert-equal 'b (caar (graph-neighbors g 'a)) "Neighbor: "))

  ;; BFS
  (let ((g (graph-make)))
    (graph-add-edge g 0 1)
    (graph-add-edge g 0 2)
    (graph-add-edge g 1 3)
    (graph-add-edge g 2 3)
    (let ((order nil))
      (bfs g 0 :visit (lambda (v) (push v order)))
      (assert-equal 4 (length order) "BFS visited: ")))

  ;; DFS
  (let ((g (graph-make)))
    (graph-add-edge g 'a 'b)
    (graph-add-edge g 'a 'c)
    (graph-add-edge g 'b 'd)
    (let ((visited (dfs g :visit (lambda (v) (declare (ignore v))))))
      (assert-equal 4 (ht-size visited) "DFS visited all: ")))

  ;; Union-Find
  (let ((uf (uf-make 5)))
    (uf-union uf 0 1)
    (uf-union uf 1 2)
    (uf-union uf 3 4)
    (assert-true (uf-connected-p uf 0 2) "UF connected 0-2: ")
    (assert-true (uf-connected-p uf 3 4) "UF connected 3-4: ")
    (assert-false (uf-connected-p uf 0 3) "UF not connected 0-3: ")
    (assert-equal 2 (uf-count-sets uf) "UF set count: ")
    (uf-union uf 0 3)
    (assert-true (uf-connected-p uf 0 3) "UF after merge: ")
    (assert-equal 1 (uf-count-sets uf) "UF one set: "))

  ;; DAG Topological Sort
  (let ((g (graph-make :directed-p t)))
    (graph-add-edge g 5 2)
    (graph-add-edge g 5 0)
    (graph-add-edge g 4 0)
    (graph-add-edge g 4 1)
    (graph-add-edge g 2 3)
    (graph-add-edge g 3 1)
    (assert-false (dag-has-cycle-p g) "DAG no cycle: ")
    (let ((topo (dag-topo-sort g)))
      (assert-equal 6 (length topo) "Topo sort length: ")
      (assert-true (< (position 5 topo) (position 2 topo)) "5 before 2: ")))

  ;; DAG with cycle
  (let ((g (graph-make :directed-p t)))
    (graph-add-edge g 0 1)
    (graph-add-edge g 1 2)
    (graph-add-edge g 2 0)
    (assert-true (dag-has-cycle-p g) "DAG has cycle: "))

  ;; Dijkstra
  (let ((g (graph-make :directed-p t)))
    (graph-add-edge g 0 1 4)
    (graph-add-edge g 0 2 1)
    (graph-add-edge g 2 1 2)
    (graph-add-edge g 1 3 1)
    (graph-add-edge g 2 3 5)
    (let ((result (dijkstra g 0)))
      (let ((dist (car result)))
        (assert-equal 0 (ht-get dist 0) "Dijkstra start: ")
        (assert-equal 3 (ht-get dist 1) "Dijkstra to 1: ")
        (assert-equal 1 (ht-get dist 2) "Dijkstra to 2: ")
        (assert-equal 4 (ht-get dist 3) "Dijkstra to 3: "))))

  ;; Bloom Filter
  (let ((bf (bf-make 100 0.01)))
    (bf-add bf 'foo)
    (bf-add bf 'bar)
    (assert-true (bf-contains-p bf 'foo) "BF contains foo: ")
    (assert-true (bf-contains-p bf 'bar) "BF contains bar: ")
    (assert-false (bf-contains-p bf 'baz) "BF no baz: "))

  ;; Skip List
  (let ((sl (sl-make)))
    (sl-insert sl 5)
    (sl-insert sl 3)
    (sl-insert sl 7)
    (sl-insert sl 1)
    (assert-true (sl-find sl 3) "SL find 3: ")
    (assert-false (sl-find sl 99) "SL find missing: ")
    (assert-equal '(1 3 5 7) (sl-to-list sl) "SL sorted: ")
    (assert-true (sl-delete sl 3) "SL delete 3: ")
    (assert-equal '(1 5 7) (sl-to-list sl) "SL after delete: ")))
