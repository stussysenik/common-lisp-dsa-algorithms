(in-package #:dsa)

;; Union-Find (Disjoint Set) — near O(1) amortized with path compression + union by rank

(defstruct (union-find (:constructor uf-make (size))
                       (:conc-name uf-))
  (parent (make-array size :initial-element 0) :type simple-vector)
  (rank (make-array size :initial-element 0) :type simple-vector)
  (count size :type fixnum))

(defun uf-init (uf &optional (size (length (uf-parent uf))))
  "Initialize each element as its own set."
  (loop for i from 0 below size do
    (setf (aref (uf-parent uf) i) i
          (aref (uf-rank uf) i) 0))
  (setf (uf-count uf) size)
  uf)

(defun uf-make (size)
  "Create union-find with SIZE elements (0..size-1)."
  (let ((uf (make-union-find :parent (make-array size :initial-element 0)
                              :rank (make-array size :initial-element 0))))
    (uf-init uf size)
    uf))

(defun uf-find* (parent x)
  "Internal find with path compression."
  (if (= (aref parent x) x)
      x
      (progn
        (setf (aref parent x) (uf-find* parent (aref parent x)))
        (aref parent x))))

(defun uf-find (uf x)
  "Find root of X with path compression."
  (uf-find* (uf-parent uf) x))

(defun uf-union (uf x y)
  "Union sets containing X and Y by rank. Returns T if merged, NIL if already same."
  (let ((rx (uf-find uf x))
        (ry (uf-find uf y)))
    (when (= rx ry) (return-from uf-union nil))
    (let ((rank-x (aref (uf-rank uf) rx))
          (rank-y (aref (uf-rank uf) ry)))
      (cond
        ((< rank-x rank-y)
         (setf (aref (uf-parent uf) rx) ry))
        ((> rank-x rank-y)
         (setf (aref (uf-parent uf) ry) rx))
        (t
         (setf (aref (uf-parent uf) ry) rx)
         (incf (aref (uf-rank uf) rx)))))
    (decf (uf-count uf))
    t))

(defun uf-connected-p (uf x y)
  (= (uf-find uf x) (uf-find uf y)))

(defun uf-count-sets (uf)
  (uf-count uf))
