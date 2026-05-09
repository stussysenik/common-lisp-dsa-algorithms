(in-package #:dsa)

;; Skip List — probabilistic sorted structure, O(log n) average search/insert/delete
;; Simpler than balanced trees, uses random level generation.

(defstruct (sl-node (:constructor sl-node-make (value level))
                    (:conc-name sln-))
  value
  (forward (make-array (1+ level) :initial-element nil) :type simple-vector))

(defstruct (skip-list (:constructor sl-make (&key (max-level 16) (test #'<)))
                      (:conc-name sl-))
  (max-level max-level :type fixnum)
  (test test :type function)
  (level 1 :type fixnum)
  (header (sl-node-make nil max-level) :type sl-node))

(defun %sl-random-level (max-level)
  "Generate random level using coin flips (p = 0.5)."
  (loop for lvl from 1
        while (and (< lvl max-level) (< (random 1.0) 0.5))
        finally (return lvl)))

(defun sl-insert (sl value)
  (let* ((test (sl-test sl))
         (update (make-array (sl-max-level sl) :initial-element nil))
         (curr (sl-header sl)))
    (loop for i from (1- (sl-level sl)) downto 0 do
      (loop while (and (svref (sln-forward curr) i)
                       (funcall test (sln-value (svref (sln-forward curr) i)) value))
            do (setf curr (svref (sln-forward curr) i)))
      (setf (svref update i) curr))
    (setf curr (svref (sln-forward curr) 0))
    (when (and curr (not (funcall test value (sln-value curr)))
               (not (funcall test (sln-value curr) value)))
      (setf (sln-value curr) value)
      (return-from sl-insert sl))
    (let ((new-level (%sl-random-level (sl-max-level sl))))
      (when (> new-level (sl-level sl))
        (loop for i from (sl-level sl) below new-level do
          (setf (svref update i) (sl-header sl)))
        (setf (sl-level sl) new-level))
      (let ((node (sl-node-make value new-level)))
        (loop for i from 0 below new-level do
          (setf (svref (sln-forward node) i)
                (svref (sln-forward (svref update i)) i))
          (setf (svref (sln-forward (svref update i)) i) node)))))
  sl)

(defun sl-find (sl value)
  (let* ((test (sl-test sl))
         (curr (sl-header sl)))
    (loop for i from (1- (sl-level sl)) downto 0 do
      (loop while (and (svref (sln-forward curr) i)
                       (funcall test (sln-value (svref (sln-forward curr) i)) value))
            do (setf curr (svref (sln-forward curr) i))))
    (setf curr (svref (sln-forward curr) 0))
    (when (and curr (not (funcall test value (sln-value curr)))
               (not (funcall test (sln-value curr) value)))
      curr)))

(defun sl-delete (sl value)
  (let* ((test (sl-test sl))
         (update (make-array (sl-max-level sl) :initial-element nil))
         (curr (sl-header sl)))
    (loop for i from (1- (sl-level sl)) downto 0 do
      (loop while (and (svref (sln-forward curr) i)
                       (funcall test (sln-value (svref (sln-forward curr) i)) value))
            do (setf curr (svref (sln-forward curr) i)))
      (setf (svref update i) curr))
    (setf curr (svref (sln-forward curr) 0))
    (when (and curr (not (funcall test value (sln-value curr)))
               (not (funcall test (sln-value curr) value)))
      (loop for i from 0 below (sl-level sl) do
        (when (and (svref (sln-forward (svref update i)) i)
                   (eq (svref (sln-forward (svref update i)) i) curr))
          (setf (svref (sln-forward (svref update i)) i)
                (svref (sln-forward curr) i))))
      (loop while (and (> (sl-level sl) 1)
                       (null (svref (sln-forward (sl-header sl))
                                    (1- (sl-level sl)))))
            do (decf (sl-level sl)))
      t)))

(defun sl-to-list (sl)
  (let ((curr (svref (sln-forward (sl-header sl)) 0))
        (result nil))
    (loop while curr do
      (push (sln-value curr) result)
      (setf curr (svref (sln-forward curr) 0)))
    (nreverse result)))
