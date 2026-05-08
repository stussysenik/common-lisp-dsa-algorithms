(in-package #:dsa)

;; Union-Find / Disjoint Set Union — near O(1) amortized

(defstruct (union-find (:constructor uf-make (size))
                       (:conc-name uf-))
  (parent nil :type simple-vector)
  (rank nil :type simple-vector)
  (count 0 :type fixnum))

(defun uf-make (size)
  "Create DSU with SIZE elements, each in own set."
  (let ((uf (make-union-find)))
    (setf (uf-parent uf) (make-array size :initial-element 0)
          (uf-rank uf) (make-array size :initial-element 0)
          (uf-count uf) size)
    (dotimes (i size)
      (setf (aref (uf-parent uf) i) i))
    uf))

(defun uf-find (uf x)
  "Find root with path compression."
  (let ((parent (uf-parent uf)))
    (unless (= (aref parent x) x)
      (setf (aref parent x) (uf-find uf (aref parent x))))
    (aref parent x)))

(defun uf-union (uf x y)
  "Union sets containing X and Y by rank. Returns T if merged."
  (let ((rx (uf-find uf x))
        (ry (uf-find uf y)))
    (unless (= rx ry)
      (let ((rx-rank (aref (uf-rank uf) rx))
            (ry-rank (aref (uf-rank uf) ry)))
        (cond
          ((< rx-rank ry-rank)
           (setf (aref (uf-parent uf) rx) ry))
          ((> rx-rank ry-rank)
           (setf (aref (uf-parent uf) ry) rx))
          (t
           (setf (aref (uf-parent uf) ry) rx)
           (incf (aref (uf-rank uf) rx)))))
      (decf (uf-count uf))
      t)))

(defun uf-connected-p (uf x y)
  (= (uf-find uf x) (uf-find uf y)))

(defun uf-count-sets (uf)
  (uf-count uf))
