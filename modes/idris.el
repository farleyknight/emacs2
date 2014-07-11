
(add-to-list 'load-path "~/dev/emacs2/modes/idris-mode")
(load "~/dev/emacs2/modes/idris-mode/idris-mode")

(add-to-list 'auto-mode-alist '("\\.idr$"       . idris-mode))
