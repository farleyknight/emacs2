(add-to-list 'load-path "~/dev/emacs2/modes/rhtml-mode")
(require 'rhtml-mode)

;; Add HTML & RHTML mode
(setq auto-mode-alist (cons '("\\.html$" . rhtml-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.rhtml$" . rhtml-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.erb$" . rhtml-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.html.erb$" . rhtml-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.iphone.erb$" . rhtml-mode) auto-mode-alist))
