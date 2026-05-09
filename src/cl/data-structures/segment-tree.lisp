(in-package #:dsa)

;; Segment Tree — range sum queries and point updates, O(log n)
;; Uses 1-indexed internal array (size = 2n)

(defstruct (segment-tree (:constructor %seg-make (tree n combiner identity))
                         (:conc-name seg-))
  (tree nil :type simple-vector)
  (n 0 :type fixnum)
  (combiner #'+ :type function)
  (identity 0))

(defun seg-build (arr)
  "Internal: build segment tree from vector ARR."
  (let* ((n (length arr))
         (size (* 2 n))
         (tree (make-array size :initial-element 0))
         (st (%seg-make tree n #'+ 0)))
    (loop for i from 0 below n do
      (setf (aref tree (+ n i)) (aref arr i)))
    (loop for i from (1- n) downto 1 do
      (setf (aref tree i) (+ (aref tree (* 2 i))
                             (aref tree (1+ (* 2 i))))))
    st))

(defun seg-query (st left right)
  "Range sum query on [left, right] inclusive. O(log n)."
  (let* ((tree (seg-tree st))
         (n (seg-n st))
         (l (+ n left))
         (r (+ n right 1))
         (result (seg-identity st)))
    (loop while (< l r) do
      (when (oddp l)
        (setf result (+ result (aref tree l)))
        (incf l))
      (when (oddp r)
        (decf r)
        (setf result (+ result (aref tree r))))
      (setf l (ash l -1)
            r (ash r -1)))
    result))

(defun seg-update (st idx value)
  "Point update at idx to value. O(log n)."
  (let* ((tree (seg-tree st))
         (n (seg-n st))
         (pos (+ n idx)))
    (setf (aref tree pos) value)
    (loop while (> pos 1) do
      (setf pos (ash pos -1))
      (setf (aref tree pos) (+ (aref tree (* 2 pos))
                               (aref tree (1+ (* 2 pos)))))))
  st)

(defun seg-make (array &key (combiner #'+) (identity 0))
  "Create segment tree from ARRAY."
  (let* ((arr (coerce array 'vector))
         (st (seg-build arr)))
    (setf (seg-combiner st) combiner
          (seg-identity st) identity)
    st))
