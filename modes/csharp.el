(add-to-list 'load-path "~/dev/emacs2/modes/csharp-mode")

(autoload 'csharp-mode "csharp-mode" "Major mode for C#." t)

(add-to-list 'auto-mode-alist '("\\.cs$" . csharp-mode))

