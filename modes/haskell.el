
(add-to-list 'load-path "~/dev/emacs2/modes/haskell-mode/")
(require 'haskell-mode-autoloads)
(add-to-list 'Info-default-directory-list "~/dev/emacs2/modes/haskell-mode/")

(add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)
