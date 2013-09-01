(add-to-list 'load-path "~/dev/emacs2/modes/yaml-mode")
(require 'yaml-mode)

(add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))
