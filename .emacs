;; Indent region
(global-set-key "\C-t" 'indent-region)

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

;; CSS mode
(add-to-list 'auto-mode-alist '("\\.scss$" . css-mode))

;; Set tab-width to 2
(setq-default tab-width 2)
(setq-default indent-tabs-mode nil)
(setq tab-width 2)

;; Custom emacs backup file configuration
(setq backup-directory-alist '(("." . "~/.emacs.d/backup"))
     backup-by-copying t            ; Don't delink hardlinks
     version-control t              ; Use version numbers on backups
     delete-old-versions t          ; Automatically delete excess backups
     kept-new-versions 20           ; how many of the newest versions to keep
     kept-old-versions 5)           ; and how many of the old


(add-to-list 'load-path "~/dev/emacs2/rhtml")
(require 'rhtml-mode)

;; Add HTML & RHTML mode
(setq auto-mode-alist (cons '("\\.html$" . rhtml-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.rhtml$" . rhtml-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.erb$" . rhtml-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.html.erb$" . rhtml-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.iphone.erb$" . rhtml-mode) auto-mode-alist))

