(in-package #:dsa)

;; Dynamic Array — growable array with amortized O(1) push/pop at end
(defstruct (dynamic-array (:constructor %da-make (data))
                          (:conc-name da-))
  (data (make-array 16 :adjustable t :fill-pointer 0) :type (and vector (not simple-array))))

(defun da-make (&optional (capacity 16))
  "Create a dynamic array with initial CAPACITY."
  (%da-make (make-array capacity :adjustable t :fill-pointer 0)))

(defun da-get (da index)
  "Get element at INDEX in dynamic array."
  (when (>= index (fill-pointer (da-data da)))
    (error "Index ~D out of bounds (length ~D)" index (fill-pointer (da-data da))))
  (aref (da-data da) index))

(defun da-set (da index value)
  "Set element at INDEX in dynamic array."
  (when (>= index (fill-pointer (da-data da)))
    (error "Index ~D out of bounds (length ~D)" index (fill-pointer (da-data da))))
  (setf (aref (da-data da) index) value))

(defun da-push (da value)
  "Push VALUE onto end. O(1) amortized."
  (vector-push-extend value (da-data da)))

(defun da-pop (da)
  "Pop last element. O(1)."
  (when (zerop (fill-pointer (da-data da)))
    (error "Pop from empty dynamic-array"))
  (vector-pop (da-data da)))

(defun da-length (da)
  "Return number of elements."
  (fill-pointer (da-data da)))

(defun da-capacity (da)
  "Return current backing array capacity."
  (array-total-size (da-data da)))

(defun da-shrink (da)
  "Shrink backing array to fit current length."
  (let ((old (da-data da))
        (len (fill-pointer (da-data da))))
    (setf (da-data da) (make-array len :adjustable t :fill-pointer len))
    (replace (da-data da) old :end2 len)))
