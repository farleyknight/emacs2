(add-to-list 'load-path "~/dev/emacs2/modes/markdown-mode")

;; (autoload 'gfm-mode "gfm-mode" "Major mode for editing Mardown text." t)

(add-to-list 'auto-mode-alist '("README\\.md\\'" . gfm-mode))
(add-to-list 'auto-mode-alist '("\\.markdown$'"  . gfm-mode))