(in-package #:dsa)

;; Segment Tree — range queries and point updates in O(log n)
;; Supports sum, min, max queries via combiner function

(defstruct (segment-tree (:constructor seg-make (array &key (combiner #'+)))
                         (:conc-name seg-))
  (combiner combiner :type function)
  (n (length array) :type fixnum)
  (tree (make-array (* 2 (length array)) :initial-element 0) :type simple-vector))

(defun seg-build (seg array)
  "Build the segment tree from ARRAY."
  (let* ((n (seg-n seg))
         (tree (seg-tree seg)))
    (loop for i from 0 below n do
      (setf (aref tree (+ n i)) (aref array i)))
    (loop for i from (1- n) downto 1 do
      (setf (aref tree i)
            (funcall (seg-combiner seg)
                     (aref tree (* 2 i))
                     (aref tree (1+ (* 2 i))))))
    seg))

(defun seg-update (seg idx value)
  "Update element at IDX to VALUE. O(log n)."
  (let* ((n (seg-n seg))
         (tree (seg-tree seg))
         (combiner (seg-combiner seg))
         (pos (+ n idx)))
    (setf (aref tree pos) value)
    (loop while (> pos 1) do
      (setf pos (floor pos 2))
      (setf (aref tree pos)
            (funcall combiner
                     (aref tree (* 2 pos))
                     (aref tree (1+ (* 2 pos))))))
    seg))

(defun seg-query (seg left right)
  "Query [LEFT, RIGHT) range. O(log n)."
  (let* ((n (seg-n seg))
         (tree (seg-tree seg))
         (combiner (seg-combiner seg))
         (l (+ n left))
         (r (+ n right))
         (result nil))
    (loop while (< l r) do
      (when (oddp l)
        (setf result (if result
                         (funcall combiner result (aref tree l))
                         (aref tree l)))
        (incf l))
      (when (oddp r)
        (decf r)
        (setf result (if result
                         (funcall combiner result (aref tree r))
                         (aref tree r))))
      (setf l (floor l 2)
            r (floor r 2)))
    (or result 0)))

(defun seg-make (array &key (combiner #'+))
  "Create segment tree from ARRAY with COMBINER function."
  (let ((seg (make-segment-tree :n (length array) :combiner combiner)))
    (setf (seg-tree seg)
          (make-array (* 2 (seg-n seg)) :initial-element 0))
    (seg-build seg (coerce array 'vector))
    seg))
