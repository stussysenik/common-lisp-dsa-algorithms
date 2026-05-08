(in-package #:dsa)

;; Open-addressing hash table with linear probing.
(defvar *ht-tombstone* (gensym "TOMBSTONE"))

(defstruct (ht (:constructor ht-make (&key (capacity 16) (test #'eql) (hash-fn #'sxhash)))
               (:conc-name ht-))
  (keys (make-array capacity :initial-element nil) :type simple-vector)
  (vals (make-array capacity :initial-element nil) :type simple-vector)
  (test test :type function)
  (hash-fn hash-fn :type function)
  (sz 0 :type fixnum))

(defun ht-capacity (ht) (length (ht-keys ht)))

(defun %ht-index (ht key)
  (let* ((cap (ht-capacity ht))
         (h (funcall (ht-hash-fn ht) key))
         (test (ht-test ht))
         (tombstone nil))
    (loop for i from 0 below cap
          for idx = (mod (+ h i) cap)
          for k = (aref (ht-keys ht) idx) do
      (cond ((null k) (return (values (or tombstone idx) nil)))
            ((and (not (eq k *ht-tombstone*)) (funcall test k key))
             (return (values idx t)))
            ((and (eq k *ht-tombstone*) (null tombstone))
             (setf tombstone idx))))
    (values tombstone nil)))

(defun %ht-resize (ht new-cap)
  (let* ((old-keys (ht-keys ht))
         (old-vals (ht-vals ht))
         (old-cap (length old-keys)))
    (setf (ht-keys ht) (make-array new-cap :initial-element nil))
    (setf (ht-vals ht) (make-array new-cap :initial-element nil))
    (setf (ht-sz ht) 0)
    (loop for i from 0 below old-cap
          for k = (aref old-keys i)
          when (and k (not (eq k *ht-tombstone*))) do
      (ht-set ht k (aref old-vals i)))))

(defun ht-get (ht key &optional default)
  (multiple-value-bind (idx found) (%ht-index ht key)
    (if found (aref (ht-vals ht) idx) default)))

(defun ht-set (ht key value)
  (when (> (ht-sz ht) (floor (ht-capacity ht) 2))
    (%ht-resize ht (* 2 (ht-capacity ht))))
  (multiple-value-bind (idx found) (%ht-index ht key)
    (unless found (incf (ht-sz ht)))
    (setf (aref (ht-keys ht) idx) key
          (aref (ht-vals ht) idx) value))
  ht)

(defun ht-delete (ht key)
  (multiple-value-bind (idx found) (%ht-index ht key)
    (when found
      (setf (aref (ht-keys ht) idx) *ht-tombstone*
            (aref (ht-vals ht) idx) nil)
      (decf (ht-sz ht))
      (when (< (ht-sz ht) (floor (ht-capacity ht) 8))
        (%ht-resize ht (max 16 (floor (ht-capacity ht) 2))))
      t)))

(defun ht-contains-p (ht key)
  (nth-value 1 (%ht-index ht key)))

(defun ht-size (ht) (ht-sz ht))

(defun ht-entries (ht)
  (loop for i from 0 below (ht-capacity ht)
        for k = (aref (ht-keys ht) i)
        when (and k (not (eq k *ht-tombstone*)))
        collect (cons k (aref (ht-vals ht) i))))
