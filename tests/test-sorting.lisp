(in-package #:dsa-tests)

(defun test-sorting ()
  (format t "~%=== Sorting Tests ===~%")
  (let ((unsorted #(5 2 8 1 9 3 7 4 6))
        (sorted #(1 2 3 4 5 6 7 8 9)))

    (assert-equal sorted (bubble-sort unsorted) "Bubble sort: ")
    (assert-equal sorted (selection-sort unsorted) "Selection sort: ")
    (assert-equal sorted (insertion-sort unsorted) "Insertion sort: ")
    (assert-equal sorted (merge-sort unsorted) "Merge sort: ")
    (assert-equal sorted (quick-sort unsorted) "Quick sort: ")
    (assert-equal sorted (heap-sort unsorted) "Heap sort: ")

    ;; Counting sort
    (let ((arr #(4 2 2 8 3 3 1)))
      (assert-equal #(1 2 2 3 3 4 8)
                    (counting-sort arr) "Counting sort: "))

    ;; Edge cases
    (let ((empty #()))
      (assert-equal #() (merge-sort empty) "Merge sort empty: ")
      (assert-equal #() (bubble-sort empty) "Bubble sort empty: "))

    (let ((single #(42)))
      (assert-equal #(42) (quick-sort single) "Quick sort single: "))

    (let ((dup #(3 1 3 1 2 2)))
      (assert-equal #(1 1 2 2 3 3) (merge-sort dup) "Merge sort dup: "))))
