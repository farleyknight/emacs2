
;; Default tab width is 2 spaces
(setq-default tab-width 2)
(setq-default indent-tabs-mode nil)
(setq tab-width 2)

;; No more backup-files~
(setq backup-directory-alist `(("." . "~/.saves")))

;; align-regexp with C-a r
(global-unset-key "\C-a")
(global-set-key "\C-ar" 'align-regexp)

;; Delete trailing whitespace
(setq-default show-trailing-whitespace t)
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; Turn off startup message
(setq inhibit-startup-message t)

;; Turn "yes or no" into "y or n"
(fset 'yes-or-no-p 'y-or-n-p)

;; Ruby mode by file extension
(add-to-list 'auto-mode-alist '("\\.rb$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.treetop$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.rake$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.gemspec$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Rakefile" . ruby-mode))
(add-to-list 'auto-mode-alist '("Gemfile" . ruby-mode))


