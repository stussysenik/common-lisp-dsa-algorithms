(in-package #:dsa)

;; Searching Algorithms

(defun linear-search (vec value &key (test #'eql) (key #'identity))
  "Linear search (O(n)). Returns index or NIL."
  (let ((arr (coerce vec 'vector)))
    (loop for i from 0 below (length arr) do
      (when (funcall test (funcall key (aref arr i)) value)
        (return i)))))

(defun binary-search (vec value &key (test #'<) (key #'identity))
  "Binary search (O(log n)) on sorted vector. Returns index or NIL."
  (let ((arr (coerce vec 'vector)))
    (do ((lo 0)
         (hi (1- (length arr))))
        ((> lo hi) nil)
      (let* ((mid (floor (+ lo hi) 2))
             (mid-val (funcall key (aref arr mid))))
        (cond
          ((funcall test mid-val value) (setf lo (1+ mid)))
          ((funcall test value mid-val) (setf hi (1- mid)))
          (t (return mid)))))))

(defun binary-search-first (vec value &key (test #'<) (key #'identity))
  "Binary search for first occurrence (lower bound). O(log n)."
  (let ((arr (coerce vec 'vector))
        (result nil))
    (do ((lo 0)
         (hi (1- (length arr))))
        ((> lo hi) result)
      (let* ((mid (floor (+ lo hi) 2))
             (mid-val (funcall key (aref arr mid))))
        (cond
          ((funcall test mid-val value) (setf lo (1+ mid)))
          ((funcall test value mid-val) (setf hi (1- mid)))
          (t (setf result mid
                   hi (1- mid))))))))

(defun binary-search-last (vec value &key (test #'<) (key #'identity))
  "Binary search for last occurrence (upper bound). O(log n)."
  (let ((arr (coerce vec 'vector))
        (result nil))
    (do ((lo 0)
         (hi (1- (length arr))))
        ((> lo hi) result)
      (let* ((mid (floor (+ lo hi) 2))
             (mid-val (funcall key (aref arr mid))))
        (cond
          ((funcall test mid-val value) (setf lo (1+ mid)))
          ((funcall test value mid-val) (setf hi (1- mid)))
          (t (setf result mid
                   lo (1+ mid))))))))

(defun jump-search (vec value &key (test #'<) (key #'identity))
  "Jump search (O(sqrt n)). Requires sorted array."
  (let* ((arr (coerce vec 'vector))
         (n (length arr))
         (step (isqrt n)))
    (when (zerop n) (return-from jump-search nil))
    (let ((prev 0))
      (loop while (< (funcall key (aref arr (min step n) )) value) do
        (setf prev step)
        (incf step (isqrt n))
        (when (>= prev n) (return-from jump-search nil)))
      (loop for i from prev below (min step n) do
        (when (and (not (funcall test (funcall key (aref arr i)) value))
                   (not (funcall test value (funcall key (aref arr i)))))
          (return i))))))

(defun interpolation-search (vec value &key (key #'identity))
  "Interpolation search (O(log log n) average). Uniformly distributed, sorted numeric keys."
  (let ((arr (coerce vec 'vector)))
    (do ((lo 0)
         (hi (1- (length arr))))
        ((or (> lo hi)
             (< value (funcall key (aref arr lo)))
             (> value (funcall key (aref arr hi))))
         nil)
      (let* ((lo-val (funcall key (aref arr lo)))
             (hi-val (funcall key (aref arr hi)))
             (pos (if (= lo-val hi-val)
                      lo
                      (+ lo (floor (* (- hi lo) (- value lo-val)) (- hi-val lo-val))))))
        (when (or (< pos lo) (> pos hi)) (return nil))
        (let ((pos-val (funcall key (aref arr pos))))
          (cond
            ((< pos-val value) (setf lo (1+ pos)))
            ((> pos-val value) (setf hi (1- pos)))
            (t (return pos))))))))
