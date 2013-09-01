(add-to-list 'load-path "~/dev/emacs2/modes/markdown-mode")

(autoload 'gfm-mode "markdown-mode" "Major mode for Markdown." t)

(add-to-list 'auto-mode-alist '("README\\.md" . gfm-mode))
(add-to-list 'auto-mode-alist '("\\.markdown$"  . gfm-mode))
