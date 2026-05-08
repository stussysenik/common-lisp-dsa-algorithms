(in-package #:dsa-tests)

(defun test-heap ()
  (format t "~%=== Heap & Priority Queue Tests ===~%")

  ;; Min Heap
  (let ((h (heap-make)))
    (assert-true (heap-empty-p h) "Empty: ")
    (heap-insert h 5)
    (heap-insert h 3)
    (heap-insert h 7)
    (heap-insert h 1)
    (assert-equal 4 (heap-size h) "Size 4: ")
    (assert-equal 1 (heap-peek h) "Min peek: ")
    (assert-equal 1 (heap-extract h) "Extract min 1: ")
    (assert-equal 3 (heap-extract h) "Extract min 3: ")
    (assert-equal 5 (heap-extract h) "Extract min 5: ")
    (assert-equal 7 (heap-extract h) "Extract min 7: ")
    (assert-true (heap-empty-p h) "Empty: "))

  ;; Max Heap
  (let ((h (heap-make :test #'>)))
    (heap-insert h 5)
    (heap-insert h 3)
    (heap-insert h 7)
    (assert-equal 7 (heap-peek h) "Max peek: ")
    (assert-equal 7 (heap-extract h) "Extract max: ")
    (assert-equal 5 (heap-extract h) "Extract max: "))

  ;; Heapify
  (let* ((h (heapify #(5 3 7 1 4 2) :test #'<)))
    (assert-equal 1 (heap-extract h) "Heapify min: ")
    (assert-equal 2 (heap-extract h) "Heapify min: ")
    (assert-equal 3 (heap-extract h) "Heapify min: "))

  ;; Priority Queue
  (let ((pq (pq-make :kind :max)))
    (pq-insert pq 10)
    (pq-insert pq 5)
    (pq-insert pq 20)
    (assert-equal 20 (pq-peek pq) "PQ max peek: ")
    (assert-equal 20 (pq-extract-max pq) "PQ extract max: ")
    (assert-equal 10 (pq-extract-max pq) "PQ extract max: "))

  (let ((pq (pq-make :kind :min)))
    (pq-insert pq 10)
    (pq-insert pq 5)
    (pq-insert pq 20)
    (assert-equal 5 (pq-extract-min pq) "PQ min: ")
    (assert-equal 10 (pq-extract-min pq) "PQ min: ")))
