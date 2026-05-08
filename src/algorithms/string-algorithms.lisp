(in-package #:dsa)

;; String Algorithms — pattern matching and text processing from scratch

(defun kmp-search (text pattern)
  "Knuth-Morris-Pratt string matching (O(n+m)). Returns list of starting indices."
  (let* ((n (length text))
         (m (length pattern)))
    (when (zerop m) (return-from kmp-search nil))
    (let ((lps (lps-array pattern))
          (matches nil)
          (i 0) (j 0))
      (loop while (< i n) do
        (if (char= (char pattern j) (char text i))
            (progn (incf i) (incf j))
            (if (= j 0)
                (incf i)
                (setf j (aref lps (1- j)))))
        (when (= j m)
          (push (- i j) matches)
          (setf j (aref lps (1- j)))))
      (nreverse matches))))

(defun lps-array (pattern)
  "Compute Longest Proper Prefix which is also Suffix array (used by KMP)."
  (let* ((m (length pattern))
         (lps (make-array m :initial-element 0 :element-type 'fixnum))
         (len 0)
         (i 1))
    (loop while (< i m) do
      (if (char= (char pattern i) (char pattern len))
          (progn (incf len)
                 (setf (aref lps i) len)
                 (incf i))
          (if (= len 0)
              (progn (setf (aref lps i) 0) (incf i))
              (setf len (aref lps (1- len))))))
    lps))

(defun rabin-karp (text pattern &optional (base 256))
  "Rabin-Karp string matching with rolling hash (O(n) average). Returns list of start indices."
  (let* ((n (length text))
         (m (length pattern))
         (q 1000000007)  ;; large prime
         (h (expt base (1- m)))
         (p-hash 0)
         (t-hash 0)
         (matches nil))
    (when (or (zerop m) (> m n)) (return-from rabin-karp nil))
    ;; Compute initial hashes
    (loop for i from 0 below m do
      (setf p-hash (mod (+ (* base p-hash) (char-code (char pattern i))) q))
      (setf t-hash (mod (+ (* base t-hash) (char-code (char text i))) q)))
    (loop for i from 0 to (- n m) do
      (when (= p-hash t-hash)
        ;; Verify character by character
        (when (loop for j from 0 below m
                    always (char= (char text (+ i j)) (char pattern j)))
          (push i matches)))
      ;; Roll hash
      (when (< i (- n m))
        (setf t-hash (mod (+ (* base (- t-hash (* (char-code (char text i)) h)))
                             (char-code (char text (+ i m))))
                          q))
        (when (< t-hash 0) (incf t-hash q))))
    (nreverse matches)))

(defun z-algorithm (text pattern)
  "Z-algorithm for pattern matching (O(n+m)). Returns list of start indices."
  (let* ((concat (concatenate 'string pattern "$" text))
         (len (length concat))
         (plen (length pattern))
         (z (make-array len :initial-element 0 :element-type 'fixnum))
         (matches nil)
         (l 0) (r 0))
    (loop for i from 1 below len do
      (when (<= i r)
        (setf (aref z i) (min (- r i -1) (aref z (- i l)))))
      (loop while (and (< (+ i (aref z i)) len)
                       (char= (char concat (aref z i))
                              (char concat (+ i (aref z i)))))
            do (incf (aref z i)))
      (when (> (+ i (aref z i) -1) r)
        (setf l i
              r (+ i (aref z i) -1)))
      (when (= (aref z i) plen)
        (push (- i plen 1) matches)))
    (nreverse matches)))

(defun manacher (s)
  "Manacher's algorithm — longest palindromic substring in O(n). Returns (start . length)."
  (let* ((t-str (with-output-to-string (out)
                  (princ #\# out)
                  (loop for c across s do
                    (princ c out)
                    (princ #\# out))))
         (n (length t-str))
         (p (make-array n :initial-element 0 :element-type 'fixnum))
         (center 0) (right 0)
         (max-len 0) (max-center 0))
    (loop for i from 0 below n do
      (let ((mirror (- (* 2 center) i)))
        (when (< i right)
          (setf (aref p i) (min (- right i) (aref p mirror))))
        ;; Expand
        (loop while (and (>= (- i (1+ (aref p i))) 0)
                         (< (+ i (1+ (aref p i))) n)
                         (char= (char t-str (- i (1+ (aref p i))))
                                (char t-str (+ i (1+ (aref p i))))))
              do (incf (aref p i)))
        (when (> (+ i (aref p i)) right)
          (setf center i
                right (+ i (aref p i))))
        (when (> (aref p i) max-len)
          (setf max-len (aref p i)
                max-center i))))
    (let ((start (floor (- max-center max-len) 2)))
      (cons start max-len))))

(defun lcs-string (a b)
  "Longest Common Substring (not subsequence). O(n*m) DP."
  (let* ((m (length a))
         (n (length b))
         (dp (make-array (list (1+ m) (1+ n)) :initial-element 0 :element-type 'fixnum))
         (max-len 0)
         (end-pos 0))
    (loop for i from 1 to m do
      (loop for j from 1 to n do
        (when (char= (char a (1- i)) (char b (1- j)))
          (setf (aref dp i j) (1+ (aref dp (1- i) (1- j))))
          (when (> (aref dp i j) max-len)
            (setf max-len (aref dp i j)
                  end-pos i)))))
    (subseq a (- end-pos max-len) end-pos)))
