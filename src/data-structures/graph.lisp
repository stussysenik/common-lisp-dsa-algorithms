(in-package #:dsa)

;; Graph — adjacency list representation, supports directed/undirected, weighted edges

(defstruct (graph (:constructor graph-make (&key (directed-p nil)))
                  (:conc-name g-))
  (vertices (ht-make :capacity 64) :type ht)
  (directed-p directed-p :type boolean)

  (vertex-count 0 :type fixnum)
  (edge-count 0 :type fixnum))

(defstruct (edge (:constructor edge-make (to &optional weight)))
  to weight)

(defun graph-add-vertex (g vertex)
  "Add VERTEX to graph. O(1)."
  (unless (ht-contains-p (g-vertices g) vertex)
    (ht-set (g-vertices g) vertex (ht-make :capacity 8))
    (incf (g-vertex-count g)))
  g)

(defun graph-add-edge (g from to &optional weight)
  "Add edge FROM -> TO with optional WEIGHT. O(1)."
  (graph-add-vertex g from)
  (graph-add-vertex g to)
  (let ((adj (ht-get (g-vertices g) from)))
    (ht-set adj to (edge-make to weight))
    (incf (g-edge-count g)))
  (unless (g-directed-p g)
    (let ((adj (ht-get (g-vertices g) to)))
      (ht-set adj from (edge-make from weight))))
  g)

(defun graph-remove-edge (g from to)
  "Remove edge FROM -> TO. O(1)."
  (let ((adj (ht-get (g-vertices g) from)))
    (when (and adj (ht-contains-p adj to))
      (ht-delete adj to)
      (decf (g-edge-count g))))
  (unless (g-directed-p g)
    (let ((adj (ht-get (g-vertices g) to)))
      (when (and adj (ht-contains-p adj from))
        (ht-delete adj from))))
  g)

(defun graph-neighbors (g vertex)
  "Return list of (to . weight) pairs for VERTEX."
  (let ((adj (ht-get (g-vertices g) vertex)))
    (when adj
      (mapcar (lambda (pair)
                (let ((edge (cdr pair)))
                  (cons (edge-to edge) (edge-weight edge))))
              (ht-entries adj)))))

(defun graph-vertices (g)
  "Return list of all vertices."
  (mapcar #'car (ht-entries (g-vertices g))))

(defun graph-edge-weight (g from to)
  "Return weight of edge FROM -> TO, or NIL."
  (let ((adj (ht-get (g-vertices g) from)))
    (when adj
      (let ((edge (ht-get adj to)))
        (when edge
          (edge-weight edge))))))

(defun graph-has-vertex-p (g vertex)
  (ht-contains-p (g-vertices g) vertex))
