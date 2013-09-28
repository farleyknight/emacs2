;; Custom Ruby mode for better indentation
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

(add-to-list 'auto-mode-alist '("\\.cr$"       . ruby-mode))

;; Standard configuration options
(setq ruby-deep-indent-paren       nil)
(setq ruby-deep-indent-paren-style nil)
(setq ruby-deep-arglist            nil)

;; Add RSpec mode
;;(add-to-list 'load-path "~/dev/emacs2/modes/rspec-mode")
;;(load "~/dev/emacs2/modes/rspec-mode/rspec-mode")
;; (require 'rspec-mode)
