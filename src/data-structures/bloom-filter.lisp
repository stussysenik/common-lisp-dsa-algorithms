(in-package #:dsa)

;; Bloom Filter — probabilistic set data structure. No false negatives, configurable false positive rate.

(defstruct (bloom-filter (:constructor bf-make (expected-items false-positive-rate))
                         (:conc-name bf-))
  (bits nil :type simple-bit-vector)
  (size 0 :type fixnum)
  (hash-count 0 :type fixnum))

(defun bf-make (expected-items false-positive-rate)
  "Create a bloom filter with optimal size and hash count."
  (let* ((n (float expected-items 1.0))
         (p (float false-positive-rate 1.0))
         (m (ceiling (- (/ (* n (log p)) (expt (log 2) 2)))))
         (k (max 1 (round (* (/ m n) (log 2))))))
    (make-bloom-filter :bits (make-array m :element-type 'bit :initial-element 0)
                       :size m
                       :hash-count k)))

(defun %bf-double-hash (item seed size)
  "Double hashing: (hash1(item) + seed * hash2(item)) mod size"
  (mod (+ (sxhash item)
          (* seed (sxhash (cons seed item))))
       size))

(defun bf-add (bf item)
  "Add ITEM to the bloom filter."
  (dotimes (i (bf-hash-count bf))
    (setf (sbit (bf-bits bf) (%bf-double-hash item (1+ i) (bf-size bf))) 1))
  bf)

(defun bf-contains-p (bf item)
  "Check if ITEM might be present. No false negatives, configurable false positives."
  (dotimes (i (bf-hash-count bf) t)
    (when (zerop (sbit (bf-bits bf) (%bf-double-hash item (1+ i) (bf-size bf))))
      (return nil))))

(defun bf-clear (bf)
  "Clear all bits in the filter."
  (fill (bf-bits bf) 0)
  bf)
