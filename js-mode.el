
(load "~/dev/emacs2/js-beautify")

(defun beautify-if-javascript ()
  (when (and (stringp buffer-file-name)
             (or
              ;; Javascript files
              (string-match "\\.js$" buffer-file-name)
              ))
    (js-beautify-buffer)))

;; (add-hook 'before-save-hook 'beautify-if-javascript)
