
(load "~/dev/emacs2/functionality/ansi-color")

(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)
(add-to-list 'comint-output-filter-functions 'ansi-color-process-output)


 (add-hook 'eshell-preoutput-filter-functions
           'ansi-color-apply)
