(in-package #:dsa)

;; Segment Tree — range queries and point updates in O(log n)
;; 1-indexed internal tree for sum queries (customizable via combiner)

(defstruct (segment-tree (:constructor seg-make (tree n combiner identity))
                         (:conc-name seg-))
  (tree nil :type simple-vector)
  (n 0 :type fixnum)
  (combiner #'+ :type function)
  (identity 0))

(defun seg-build (arr)
  "Build segment tree from vector ARR. Returns segment tree."
  (let* ((n (length arr))
         (tree-size (* 2 n))
         (tree (make-array tree-size :initial-element 0))
         (st (seg-make tree n #'+ 0)))
    ;; Fill leaves
    (loop for i from 0 below n do
      (setf (aref tree (+ n i)) (aref arr i)))
    ;; Build internal nodes bottom-up
    (loop for i from (1- n) downto 1 do
      (setf (aref tree i) (+ (aref tree (* 2 i))
                             (aref tree (1+ (* 2 i))))))
    st))
