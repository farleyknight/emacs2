(add-to-list 'load-path "~/dev/emacs2/modes/rhtml-mode")

(autoload 'rhtml-mode "rhtml-mode" "Major mode for rhtml and html.erb" t)

;; Add HTML & RHTML mode
(setq auto-mode-alist (cons '("\\.html$" . rhtml-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.rhtml$" . rhtml-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.html.erb$" . rhtml-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.iphone.erb$" . rhtml-mode) auto-mode-alist))
