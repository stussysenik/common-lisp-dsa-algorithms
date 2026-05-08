(in-package #:dsa)

;; Dynamic Programming — classic interview problems

(defun fibonacci-dp (n)
  "Fibonacci number using DP (O(n) time, O(1) space)."
  (if (<= n 1)
      n
      (let ((a 0) (b 1))
        (loop repeat (1- n) do
          (rotatef a b)
          (setf b (+ a b)))
        b)))

(defun knapsack-01 (weights values capacity)
  "0/1 Knapsack (O(n*W)). Returns maximum value."
  (let* ((n (length weights))
         (dp (make-array (1+ capacity) :initial-element 0 :element-type 'fixnum)))
    (dotimes (i n)
      (loop for w from capacity downto (aref weights i) do
        (let ((include (+ (aref dp (- w (aref weights i))) (aref values i))))
          (when (> include (aref dp w))
            (setf (aref dp w) include)))))
    (aref dp capacity)))

(defun longest-common-subsequence (a b)
  "LCS of two sequences (O(n*m)). Returns the LCS length and the sequence."
  (let* ((m (length a))
         (n (length b))
         (dp (make-array (list (1+ m) (1+ n)) :initial-element 0 :element-type 'fixnum)))
    (loop for i from 1 to m do
      (loop for j from 1 to n do
        (if (equalp (aref a (1- i)) (aref b (1- j)))
            (setf (aref dp i j) (1+ (aref dp (1- i) (1- j))))
            (setf (aref dp i j) (max (aref dp (1- i) j)
                                     (aref dp i (1- j)))))))
    ;; Reconstruct
    (let ((result nil)
          (i m) (j n))
      (loop while (and (> i 0) (> j 0)) do
        (if (equalp (aref a (1- i)) (aref b (1- j)))
            (progn (push (aref a (1- i)) result)
                   (decf i) (decf j))
            (if (> (aref dp (1- i) j) (aref dp i (1- j)))
                (decf i)
                (decf j))))
      (values (aref dp m n) (coerce result 'vector)))))

(defun longest-increasing-subsequence (seq)
  "LIS in O(n log n) using patience sorting. Returns the subsequence."
  (let* ((arr (coerce seq 'vector))
         (n (length arr)))
    (when (zerop n) (return-from longest-increasing-subsequence #()))
    (let ((tails (make-array n :initial-element 0 :element-type 'fixnum))
          (prev (make-array n :initial-element -1 :element-type 'fixnum))
          (len 0))
      (dotimes (i n)
        (let* ((x (aref arr i))
               (lo 0) (hi len))
          (loop while (< lo hi) do
            (let ((mid (floor (+ lo hi) 2)))
              (if (< (aref arr (aref tails mid)) x)
                  (setf lo (1+ mid))
                  (setf hi mid))))
          (setf (aref prev i) (if (> lo 0) (aref tails (1- lo)) -1))
          (setf (aref tails lo) i)
          (when (= lo len)
            (incf len))))
      ;; Reconstruct
      (let ((result (make-array len))
            (k (aref tails (1- len))))
        (loop for i from (1- len) downto 0 do
          (setf (aref result i) (aref arr k))
          (setf k (aref prev k)))
        result))))

(defun edit-distance (a b)
  "Levenshtein distance between A and B (O(n*m))."
  (let* ((m (length a))
         (n (length b))
         (prev (make-array (1+ n) :element-type 'fixnum))
         (curr (make-array (1+ n) :element-type 'fixnum)))
    (dotimes (j (1+ n))
      (setf (aref prev j) j))
    (dotimes (i m)
      (setf (aref curr 0) (1+ i))
      (dotimes (j n)
        (let ((cost (if (char= (aref a i) (aref b j)) 0 1)))
          (setf (aref curr (1+ j))
                (min (1+ (aref prev (1+ j)))
                     (1+ (aref curr j))
                     (+ (aref prev j) cost)))))
      (rotatef prev curr))
    (aref prev n)))

(defun coin-change (coins amount)
  "Minimum number of coins to make AMOUNT (unbounded). O(n*amount). Returns count or NIL."
  (let ((dp (make-array (1+ amount) :initial-element most-positive-fixnum :element-type 'fixnum)))
    (setf (aref dp 0) 0)
    (loop for i from 1 to amount do
      (loop for coin across coins do
        (when (<= coin i)
          (let ((prev (aref dp (- i coin))))
            (when (/= prev most-positive-fixnum)
              (setf (aref dp i) (min (aref dp i) (1+ prev))))))))
    (let ((result (aref dp amount)))
      (if (= result most-positive-fixnum) nil result))))

(defun coin-change-ways (coins amount)
  "Number of ways to make AMOUNT (unbounded). O(n*amount)."
  (let ((dp (make-array (1+ amount) :initial-element 0 :element-type 'fixnum)))
    (setf (aref dp 0) 1)
    (loop for coin across coins do
      (loop for i from coin to amount do
        (incf (aref dp i) (aref dp (- i coin)))))
    (aref dp amount)))
