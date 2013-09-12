(add-to-list 'load-path "~/dev/emacs2/modes/json-mode")

(autoload 'json-mode "json-mode" "Major mode for JSON." t)

(add-to-list 'auto-mode-alist '("\\.json$" . json-mode))
