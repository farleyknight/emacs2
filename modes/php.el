(add-to-list 'load-path "~/dev/emacs2/modes/php-mode")
(require 'php-mode)

(add-to-list 'auto-mode-alist '("\\.php$" . php-mode))
(add-to-list 'auto-mode-alist '("\\.inc$" . php-mode))
