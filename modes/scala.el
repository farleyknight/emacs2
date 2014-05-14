
(add-to-list 'load-path "~/dev/emacs2/modes/scala-mode")

(autoload 'scala-mode "scala-mode" "Major mode for Scala." t)

(add-to-list 'auto-mode-alist '("\\.scala$"  . scala-mode))
(add-to-list 'auto-mode-alist '("build.sbt$" . scala-mode))
