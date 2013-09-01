;; Indent entire buffer when saving
(defun indent-entire-buffer ()
  "Indent the whole buffer."
  (indent-region (point-min) (point-max) nil))

(defun indent-only-code ()
  "Indent"
  (when (and (stringp buffer-file-name)
             (or
              ;; Ruby files
              (string-match "\\.rb$" buffer-file-name)
              (string-match "\\.erb$" buffer-file-name)
              (string-match "Gemfile" buffer-file-name)
              (string-match "Rakefile" buffer-file-name)
              ;; Javascript files
              (string-match "\\.js$" buffer-file-name)
              ;; CSS files
              (string-match "\\.css$" buffer-file-name)
              (string-match "\\.scss$" buffer-file-name)
              ))
    (indent-entire-buffer)))

(add-hook 'before-save-hook 'indent-only-code)
