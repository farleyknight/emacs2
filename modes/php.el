(add-to-list 'load-path "~/dev/emacs2/modes/php-mode")

(autoload 'php-mode "php-mode" "Major mode for PHP." t)

(add-to-list 'auto-mode-alist '("\\.php$" . php-mode))
(add-to-list 'auto-mode-alist '("\\.inc$" . php-mode))
