(in-package #:dsa)

;; Bloom Filter — probabilistic set, no false negatives

(defstruct (bloom-filter (:constructor %bf-make (bits m k))
                         (:conc-name bf-))
  (bits nil :type simple-bit-vector)
  (m 0 :type fixnum)
  (k 0 :type fixnum))

(defun bf-make (expected-items false-positive-rate)
  "Create optimal bloom filter."
  (let* ((n (float expected-items))
         (p (float false-positive-rate))
         (m (ceiling (- (/ (* n (log p)) (* (log 2) (log 2))))))
         (k (max 1 (round (* (/ m n) (log 2))))))
    (let ((bf (%bf-make (make-array m :element-type 'bit :initial-element 0)
                        m
                        k)))
      bf)))

(defun %bf-hash (item i m)
  (mod (+ (sxhash item) (* i (sxhash (cons i item)))) m))

(defun bf-add (bf item)
  (dotimes (i (bf-k bf))
    (setf (sbit (bf-bits bf) (%bf-hash item i (bf-m bf))) 1))
  bf)

(defun bf-contains-p (bf item)
  (dotimes (i (bf-k bf) t)
    (when (zerop (sbit (bf-bits bf) (%bf-hash item i (bf-m bf))))
      (return nil))))

(defun bf-clear (bf)
  (fill (bf-bits bf) 0)
  bf)
