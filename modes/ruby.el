(add-to-list 'load-path "~/dev/emacs2/modes/ruby-mode-indent")

;; Ruby mode by file extension
(add-to-list 'auto-mode-alist '("\\.rb$"       . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.thor$"     . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.treetop$"  . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.rake$"     . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.gemspec$"  . ruby-mode))
(add-to-list 'auto-mode-alist '("Rakefile$"    . ruby-mode))
(add-to-list 'auto-mode-alist '("Gemfile$"     . ruby-mode))
(add-to-list 'auto-mode-alist '("Guardfile$"   . ruby-mode))

;; Ugly indent:
;;
;; User.all({
;;        :joins => :account,
;;        :conditions => {:delete_at => nil}
;;      })
;;
;; Pretty indent:
;;
;; User.all({
;;   :joins => :account,
;;   :conditions => {:delete_at => nil}
;; })


(setq ruby-deep-indent-paren       nil)
(setq ruby-deep-indent-paren-style nil)
(setq ruby-deep-arglist            nil)

(defadvice ruby-indent-line (after unindent-closing-paren activate)
  (let ((column (current-column))
         indent offset)
    (save-excursion
      (back-to-indentation)
      (let ((state (syntax-ppss)))
        (setq offset (- column (current-column)))
        (when (and (eq (char-after) ?\))
                   (not (zerop (car state))))
          (goto-char (cadr state))
          (setq indent (current-indentation)))))
    (when indent
      (indent-line-to indent)
      (when (> offset 0) (forward-char offset)))))

