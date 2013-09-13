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
