;; Indent entire buffer when saving

(defun indent-entire-buffer ()
  "Indent the whole buffer."
  (interactive)
  (indent-region (point-min) (point-max) nil))

(global-set-key (kbd "C-x t") 'indent-entire-buffer)
