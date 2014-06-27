
(add-to-list 'load-path "~/dev/emacs2/modes/crystal-mode")

(require 'crystal-mode)

(add-to-list 'auto-mode-alist '("\\.cr$" . crystal-mode))
