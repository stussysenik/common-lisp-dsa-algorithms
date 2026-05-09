(in-package #:dsa)

;; Queue — FIFO using two stacks (amortized O(1))

(defstruct (queue (:constructor queue-make ()))
  (in-stack nil :type list)
  (out-stack nil :type list)
  (count 0 :type fixnum))

(defun %queue-flush (q)
  "Move elements from in-stack to out-stack when out-stack is empty."
  (when (null (queue-out-stack q))
    (loop while (queue-in-stack q) do
      (push (pop (queue-in-stack q)) (queue-out-stack q)))))

(defun queue-enqueue (q value)
  "Add to back. O(1)."
  (push value (queue-in-stack q))
  (incf (queue-count q))
  q)

(defun queue-dequeue (q)
  "Remove from front. O(1) amortized."
  (when (queue-empty-p q)
    (error "Dequeue from empty queue"))
  (%queue-flush q)
  (decf (queue-count q))
  (pop (queue-out-stack q)))

(defun queue-peek (q)
  "Return front without removing. O(1) amortized."
  (when (queue-empty-p q)
    (error "Peek from empty queue"))
  (%queue-flush q)
  (first (queue-out-stack q)))

(defun queue-empty-p (q)
  (= (queue-count q) 0))

(defun queue-size (q)
  (queue-count q))
