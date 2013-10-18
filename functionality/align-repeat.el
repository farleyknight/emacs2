
(defun align-repeat (start end regexp)
  "Repeat alignment with respect to
     the given regular expression."
  (interactive "r\nsAlign regexp: ")
  (align-regexp start end
                (concat "\\(\\s-*\\)" regexp) 1 1 t))

(defun align-spaces ()
  "Align on spaces"
  (interactive)
  (align-regexp (mark) (point)
                (concat "\\(\\s-*\\)" "\\(\\s-+\\)") 1 1 t)
  (indent-entire-buffer))
