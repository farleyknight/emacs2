
(add-to-list 'load-path "~/dev/emacs2/modes/scala-mode2")

(autoload 'scala-mode "scala-mode2" "Major mode for Scala." t)

(add-to-list 'auto-mode-alist '("\\.scala$" . scala-mode))
