(in-package #:dsa)

;; Binary Heap — Min-heap by default. Pass :test #'> for max-heap.
;; Backed by a dynamic array.

(defstruct (heap (:constructor heap-make (&key (test #'<) (capacity 16)))
                 (:conc-name h-))
  (data (make-array capacity :adjustable t :fill-pointer 0))
  (test test :type function)
  (capacity capacity :type fixnum))

(defun heap-empty-p (hp)
  (zerop (fill-pointer (h-data hp))))

(defun heap-size (hp)
  (fill-pointer (h-data hp)))

(defun heap-peek (hp)
  "Return root without removing. O(1)."
  (when (heap-empty-p hp)
    (error "Peek from empty heap"))
  (aref (h-data hp) 0))

(defun %heap-parent (i) (floor (1- i) 2))
(defun %heap-left (i) (1+ (* 2 i)))
(defun %heap-right (i) (+ 2 (* 2 i)))

(defun %heap-sift-up (hp idx)
  "Bubble element at IDX up to restore heap property."
  (let ((data (h-data hp))
        (test (h-test hp))
        (val (aref (h-data hp) idx)))
    (loop while (> idx 0) do
      (let ((parent (%heap-parent idx)))
        (if (funcall test val (aref data parent))
            (progn
              (setf (aref data idx) (aref data parent))
              (setf idx parent))
            (return))))
    (setf (aref data idx) val)))

(defun %heap-sift-down (hp idx)
  "Bubble element at IDX down to restore heap property."
  (let* ((data (h-data hp))
         (test (h-test hp))
         (n (fill-pointer data))
         (val (aref data idx)))
    (loop
      (let ((smallest idx)
            (left (%heap-left idx))
            (right (%heap-right idx)))
        (when (and (< left n) (funcall test (aref data left) val))
          (setf smallest left))
        (when (and (< right n) (funcall test (aref data right) (aref data smallest)))
          (setf smallest right))
        (if (/= smallest idx)
            (progn
              (setf (aref data idx) (aref data smallest))
              (setf idx smallest))
            (return))))
    (setf (aref data idx) val)))

(defun heap-insert (hp value)
  "Insert VALUE. O(log n)."
  (vector-push-extend value (h-data hp))
  (%heap-sift-up hp (1- (fill-pointer (h-data hp))))
  hp)

(defun heap-extract (hp)
  "Remove and return root. O(log n)."
  (when (heap-empty-p hp)
    (error "Extract from empty heap"))
  (let* ((data (h-data hp))
         (last (1- (fill-pointer data)))
         (result (aref data 0)))
    (setf (aref data 0) (aref data last))
    (decf (fill-pointer data))
    (unless (heap-empty-p hp)
      (%heap-sift-down hp 0))
    result))

(defun heapify (sequence &key (test #'<))
  "Build heap from sequence in O(n)."
  (let* ((n (length sequence))
         (hp (heap-make :test test :capacity n)))
    (loop for val across (if (listp sequence) (coerce sequence 'vector) sequence) do
      (vector-push-extend val (h-data hp)))
    (loop for i from (floor (1- (heap-size hp)) 2) downto 0 do
      (%heap-sift-down hp i))
    hp))
