(in-package #:dsa)

;; Coalton-typed data structures and algorithms
;; Coalton is a statically-typed functional language embedded in Common Lisp.
;; When Coalton is loaded, we provide type-safe alternatives.

#+coalton
(coalton-filetoplevel
  (define-type (BinaryTree :a)
    Leaf
    (Node :a (BinaryTree :a) (BinaryTree :a)))

  (declare btree-insert ((Ord :a) => :a -> BinaryTree :a -> BinaryTree :a))
  (define (btree-insert x tree)
    (match tree
      ((Leaf) (Node x Leaf Leaf))
      ((Node v left right)
       (if (< x v)
           (Node v (btree-insert x left) right)
           (Node v left (btree-insert x right))))))

  (declare btree-find ((Ord :a) => :a -> BinaryTree :a -> Boolean))
  (define (btree-find x tree)
    (match tree
      ((Leaf) False)
      ((Node v left right)
       (cond
         ((== x v) True)
         ((< x v) (btree-find x left))
         (True (btree-find x right))))))

  (declare btree-size (BinaryTree :a -> Integer))
  (define (btree-size tree)
    (match tree
      ((Leaf) 0)
      ((Node _ left right)
       (+ 1 (+ (btree-size left) (btree-size right))))))

  ;; Coalton graph type
  (define-type (Graph :a)
    (Graph (List :a) (List (Tuple :a :a Integer))))

  (declare graph-empty (Graph :a))
  (define graph-empty (Graph Nil Nil))

  (declare graph-add-vertex (:a -> Graph :a -> Graph :a))
  (define (graph-add-vertex v (Graph vertices edges))
    (if (member v vertices)
        (Graph vertices edges)
        (Graph (Cons v vertices) edges)))

  (declare graph-add-edge (:a -> :a -> Integer -> Graph :a -> Graph :a))
  (define (graph-add-edge from to weight (Graph vertices edges))
    (Graph vertices (Cons (Tuple from to weight) edges))))

(coalton-filetoplevel
  ;; Coalton sorting
  (declare coalton-quicksort ((Ord :a) => List :a -> List :a))
  (define (coalton-quicksort xs)
    (match xs
      ((Nil) Nil)
      ((Cons x xs)
       (let ((smaller (filter (fn (y) (< y x)) xs))
             (larger (filter (fn (y) (>= y x)) xs)))
         (append (coalton-quicksort smaller)
                 (Cons x (coalton-quicksort larger)))))))

  (declare coalton-mergesort ((Ord :a) => List :a -> List :a))
  (define (coalton-mergesort xs)
    (let ((merge (fn (left right)
                   (match (Tuple left right)
                     ((Tuple Nil ys) ys)
                     ((Tuple xs Nil) xs)
                     ((Tuple (Cons x xs) (Cons y ys))
                      (if (<= x y)
                          (Cons x (merge xs right))
                          (Cons y (merge left ys))))))))
      (match xs
        ((Nil) Nil)
        ((Cons _ Nil) xs)
        (_ (let ((mid (floor (/ (length xs) 2))))
             (let ((left (take mid xs))
                   (right (drop mid xs)))
               (merge (coalton-mergesort left)
                      (coalton-mergesort right)))))))))

#-coalton
(warn "Coalton not available. Coalton-typed structures skipped.")
