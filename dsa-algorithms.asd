(defsystem "dsa-algorithms"
  :description "Data Structures and Algorithms from scratch in Common Lisp + Coalton"
  :author "DSA Lab"
  :license "MIT"
  :version "0.1.0"
  :depends-on ("alexandria" "serapeum")
  :serial t
  :components
  ((:module "src"
    :serial t
    :components
    ((:file "package")
     (:module "data-structures"
      :serial t
      :components
      ((:file "dynamic-array")
       (:file "linked-list")
       (:file "stack")
       (:file "queue")
       (:file "deque")
       (:file "heap")
       (:file "priority-queue")
       (:file "hash-table")
       (:file "lru-cache")
       (:file "binary-tree")
       (:file "binary-search-tree")
       (:file "avl-tree")
       (:file "red-black-tree")
       (:file "trie")
       (:file "segment-tree")
       (:file "graph")
       (:file "dag")
       (:file "union-find")
       (:file "bloom-filter")
       (:file "skip-list")))
     (:module "algorithms"
      :serial t
      :components
      ((:file "sorting")
       (:file "searching")
       (:file "graph-algorithms")
       (:file "dynamic-programming")
       (:file "string-algorithms")))))
   (:module "tests"
    :serial t
    :components
    ((:file "package")
     (:file "test-dynamic-array")
     (:file "test-linked-list")
     (:file "test-stack-queue")
     (:file "test-heap")
     (:file "test-trees")
     (:file "test-graph")
     (:file "test-sorting")
     (:file "test-algorithms")))))
