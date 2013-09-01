(add-to-list 'load-path "~/dev/emacs2/modes/yaml-mode")

(autoload 'yaml-mode "yaml-mode" "Major mode for Yaml." t)

(add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))
