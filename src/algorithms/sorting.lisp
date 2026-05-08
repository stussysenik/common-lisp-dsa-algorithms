(in-package #:dsa)

;; Sorting Algorithms — from O(n²) classics to O(n log n) workhorses

(defun bubble-sort (vec &key (test #'<) (key #'identity))
  "Bubble sort (O(n²)). Stable."
  (let ((arr (copy-seq (coerce vec 'vector))))
    (loop for i from (1- (length arr)) downto 1 do
      (loop for j from 0 below i
            for a = (aref arr j)
            for b = (aref arr (1+ j)) do
        (when (funcall test (funcall key b) (funcall key a))
          (rotatef (aref arr j) (aref arr (1+ j))))))
    arr))

(defun selection-sort (vec &key (test #'<) (key #'identity))
  "Selection sort (O(n²)). Not stable."
  (let* ((arr (copy-seq (coerce vec 'vector)))
         (n (length arr)))
    (dotimes (i (1- n))
      (let ((min-idx i))
        (loop for j from (1+ i) below n do
          (when (funcall test
                         (funcall key (aref arr j))
                         (funcall key (aref arr min-idx)))
            (setf min-idx j)))
        (unless (= min-idx i)
          (rotatef (aref arr i) (aref arr min-idx)))))
    arr))

(defun insertion-sort (vec &key (test #'<) (key #'identity))
  "Insertion sort (O(n²)). Stable. Great for small or nearly-sorted arrays."
  (let ((arr (copy-seq (coerce vec 'vector))))
    (loop for i from 1 below (length arr)
          for key-val = (aref arr i)
          for j = (1- i)
          do (loop while (and (>= j 0)
                              (funcall test
                                       (funcall key key-val)
                                       (funcall key (aref arr j))))
                do (setf (aref arr (1+ j)) (aref arr j))
                   (decf j))
             (setf (aref arr (1+ j)) key-val))
    arr))

(defun merge-sort (vec &key (test #'<) (key #'identity))
  "Merge sort (O(n log n)). Stable. Divide and conquer."
  (labels ((merge-two (left right)
             (let ((result (make-array (+ (length left) (length right))))
                   (i 0) (j 0) (k 0))
               (loop while (and (< i (length left)) (< j (length right))) do
                 (if (funcall test
                              (funcall key (aref left i))
                              (funcall key (aref right j)))
                     (progn (setf (aref result k) (aref left i)) (incf i))
                     (progn (setf (aref result k) (aref right j)) (incf j)))
                 (incf k))
               (loop while (< i (length left)) do
                 (setf (aref result k) (aref left i)) (incf i) (incf k))
               (loop while (< j (length right)) do
                 (setf (aref result k) (aref right j)) (incf j) (incf k))
               result))
           (merge-sort-rec (arr)
             (if (<= (length arr) 16)
                 (insertion-sort arr :test test :key key)
                 (let* ((mid (floor (length arr) 2))
                        (left (merge-sort-rec (subseq arr 0 mid)))
                        (right (merge-sort-rec (subseq arr mid))))
                   (merge-two left right)))))
    (merge-sort-rec (coerce vec 'vector))))

(defun quick-sort (vec &key (test #'<) (key #'identity))
  "Quicksort (O(n log n) average). Not stable. In-place on a copy."
  (let ((arr (copy-seq (coerce vec 'vector))))
    (labels ((partition (lo hi)
               (let* ((pivot (aref arr hi))
                      (pivot-key (funcall key pivot))
                      (i (1- lo)))
                 (loop for j from lo below hi do
                   (when (funcall test (funcall key (aref arr j)) pivot-key)
                     (incf i)
                     (rotatef (aref arr i) (aref arr j))))
                 (rotatef (aref arr (1+ i)) (aref arr hi))
                 (1+ i)))
             (qs (lo hi)
               (when (< lo hi)
                 (let ((p (partition lo hi)))
                   (qs lo (1- p))
                   (qs (1+ p) hi)))))
      (when (> (length arr) 0)
        (qs 0 (1- (length arr))))
      arr)))

(defun heap-sort (vec &key (test #'<) (key #'identity))
  "Heapsort (O(n log n)). Not stable."
  (let* ((arr (copy-seq (coerce vec 'vector)))
         (n (length arr))
         ;; For heap-sort we use max-heap (test is #'> for max behavior)
         (heap-test (lambda (a b) (funcall test (funcall key b) (funcall key a)))))
    (labels ((sift-down (start end)
               (let ((root start))
                 (loop while (<= (* 2 root) end) do
                   (let* ((child (* 2 root))
                          (swap root))
                     (when (and (< swap child) (funcall heap-test (aref arr child) (aref arr swap)))
                       (setf swap child))
                     (when (and (< (1+ child) end) (funcall heap-test (aref arr (1+ child)) (aref arr swap)))
                       (setf swap (1+ child)))
                     (if (= swap root)
                         (return)
                         (progn (rotatef (aref arr root) (aref arr swap))
                                (setf root swap)))))))
             (heapify ()
               (loop for start from (floor (1- n) 2) downto 0 do
                 (sift-down start (1- n)))))
      (heapify)
      (loop for end from (1- n) downto 1 do
        (rotatef (aref arr end) (aref arr 0))
        (sift-down 0 (1- end))))
    arr))

(defun counting-sort (vec &key (key #'identity))
  "Counting sort (O(n + k)). Only for non-negative integer keys."
  (let* ((arr (coerce vec 'vector))
         (n (length arr))
         (keys (map 'vector key arr)))
    (when (zerop n) (return-from counting-sort #()))
    (let* ((max-val (reduce #'max keys :initial-value (aref keys 0)))
           (min-val (reduce #'min keys :initial-value (aref keys 0)))
           (range (- max-val min-val -1))
           (count (make-array range :initial-element 0 :element-type 'fixnum))
           (output (make-array n :initial-element nil)))
      (loop for k across keys do
        (incf (aref count (- k min-val))))
      (loop for i from 1 below range do
        (incf (aref count i) (aref count (1- i))))
      (loop for i from (1- n) downto 0
            for k = (aref keys i)
            for pos = (- (aref count (- k min-val)) 1) do
        (setf (aref output pos) (aref arr i))
        (decf (aref count (- k min-val))))
      output)))

(defun radix-sort (vec &key (key #'identity))
  "Radix sort LSD (O(d*(n+b))). Integer keys only."
  (let ((arr (copy-seq (coerce vec 'vector))))
    (when (zerop (length arr)) (return-from radix-sort arr))
    (let* ((keys (map 'vector key arr))
           (max-key (reduce #'max keys :initial-value (aref keys 0))))
      (do ((exp 1 (* exp 10)))
          ((> (floor max-key exp) 0))
        (let ((output (make-array (length arr) :initial-element nil))
              (count (make-array 10 :initial-element 0)))
          (loop for k across keys do
            (incf (aref count (mod (floor k exp) 10))))
          (loop for i from 1 to 9 do
            (incf (aref count i) (aref count (1- i))))
          (loop for i from (1- (length arr)) downto 0 do
            (let* ((k (aref keys i))
                   (digit (mod (floor k exp) 10))
                   (pos (decf (aref count digit))))
              (setf (aref output pos) (aref arr i))))
          (setf arr output)))
      arr)))
