(in-package #:dsa-tests)

(defun test-algorithms ()
  (format t "~%=== Algorithm Tests ===~%")

  ;; Binary Search
  (let ((arr #(1 3 5 7 9 11 13)))
    (assert-equal 3 (binary-search arr 7) "Binary search 7: ")
    (assert-equal 0 (binary-search arr 1) "Binary search 1: ")
    (assert-equal 6 (binary-search arr 13) "Binary search 13: ")
    (assert-false (binary-search arr 8) "Binary search missing: "))

  ;; Linear Search
  (let ((arr #(10 20 30 40)))
    (assert-equal 2 (linear-search arr 30) "Linear search 30: ")
    (assert-false (linear-search arr 99) "Linear search missing: "))

  ;; KMP Search
  (let ((text "ABABDABACDABABCABAB")
        (pattern "ABABCABAB"))
    (let ((matches (kmp-search text pattern)))
      (assert-equal 1 (length matches) "KMP one match: ")
      (assert-equal 10 (first matches) "KMP at index 10: "))
    (let ((matches (kmp-search "AAAAA" "AA")))
      (assert-equal 4 (length matches) "KMP overlapping: ")))

  ;; Rabin-Karp
  (let ((text "GEEKS FOR GEEKS")
        (pattern "GEEK"))
    (let ((matches (rabin-karp text pattern)))
      (assert-true matches "RK found: ")
      (assert-equal 0 (first matches) "RK at index: ")))

  ;; Z Algorithm
  (let ((matches (z-algorithm "AABAACAADAABAABA" "AABA")))
    (assert-equal 3 (length matches) "Z-algo matches: "))

  ;; Manacher
  (let ((result (manacher "babad")))
    (assert-equal 3 (cdr result) "Manacher length 3: "))

  ;; Fibonacci DP
  (assert-equal 0 (fibonacci-dp 0) "Fib 0: ")
  (assert-equal 1 (fibonacci-dp 1) "Fib 1: ")
  (assert-equal 55 (fibonacci-dp 10) "Fib 10: ")
  (assert-equal 6765 (fibonacci-dp 20) "Fib 20: ")

  ;; 0/1 Knapsack
  (let ((weights #(2 3 4 5))
        (values #(3 4 5 6))
        (capacity 5))
    (assert-equal 7 (knapsack-01 weights values capacity) "Knapsack: "))

  ;; Longest Common Subsequence
  (let ((a "ABCDGH")
        (b "AEDFHR"))
    (assert-equal 3 (longest-common-subsequence a b) "LCS length: "))

  ;; Longest Increasing Subsequence
  (let ((seq #(10 9 2 5 3 7 101 18)))
    (assert-equal #(2 3 7 101) (longest-increasing-subsequence seq) "LIS: "))

  ;; Edit distance
  (assert-equal 3 (edit-distance "kitten" "sitting") "Edit distance: ")

  ;; Coin change
  (let ((coins #(1 2 5)))
    (assert-equal 3 (coin-change coins 11) "Coin change 11: ")
    (assert-false (coin-change #(2) 3) "Coin change impossible: "))

  ;; Longest Common Substring
  (let ((result (lcs-string "ABABC" "BABCA")))
    (assert-equal "ABAB" result "LCS substring: "))

  ;; LRU Cache
  (let ((lru (lru-make 3)))
    (lru-put lru 'a 1)
    (lru-put lru 'b 2)
    (lru-put lru 'c 3)
    (assert-equal 1 (lru-get lru 'a) "LRU get a: ")
    (lru-put lru 'd 4)
    (assert-false (lru-get lru 'b) "LRU evicted b: ")
    (assert-equal 4 (lru-get lru 'd) "LRU get d: "))

  ;; Hash Table
  (let ((h (ht-make :capacity 8)))
    (ht-set h 'foo 42)
    (ht-set h 'bar 100)
    (assert-equal 42 (ht-get h 'foo) "HT get: ")
    (assert-equal 2 (ht-size h) "HT size: ")
    (assert-true (ht-contains-p h 'foo) "HT contains: ")
    (ht-delete h 'foo)
    (assert-false (ht-contains-p h 'foo) "HT delete: ")
    (assert-equal 1 (ht-size h) "HT size after delete: "))

  ;; Hash table resize
  (let ((h (ht-make :capacity 2)))
    (dotimes (i 10)
      (ht-set h i (* i 10)))
    (assert-equal 10 (ht-size h) "HT resize: ")
    (assert-equal 50 (ht-get h 5) "HT resize verify: ")))
