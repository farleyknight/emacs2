;; Indent entire buffer when saving
(defun indent-entire-buffer ()
  "Indent the whole buffer."
  (indent-region (point-min) (point-max) nil))

(defun indent-only-code ()
  "Indent only files matching below"
  ;; TODO: Check the length of the file...
  ;; Really long files have issues with formatting..
  (when (and (stringp buffer-file-name)
             (or
              ;; Ruby files
              (string-match "\\.rb$" buffer-file-name)
              (string-match "\\.rake$" buffer-file-name)
              (string-match "\\.html.erb$" buffer-file-name)
              (string-match "Gemfile" buffer-file-name)
              (string-match "Rakefile" buffer-file-name)
              (string-match "Guardfile" buffer-file-name)
              ;; Javascript files
              (string-match "\\.js$" buffer-file-name)
              ;; JSON files
              (string-match "\\.json$" buffer-file-name)
              ;; C# files
              (string-match "\\.cs$" buffer-file-name)
              ;; Scala files
              (string-match "\\.scala$" buffer-file-name)
              ;; PHP files
              (string-match "\\.php$" buffer-file-name)
              ;; CSS files
              (string-match "\\.css$" buffer-file-name)
              (string-match "\\.css.erb$" buffer-file-name)
              (string-match "\\.scss$" buffer-file-name)
              ;; HTML files
              (string-match "\\.html$" buffer-file-name)
              )
             )
    (indent-entire-buffer)))

(add-hook 'before-save-hook 'indent-only-code)
