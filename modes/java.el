
;; (add-to-list 'load-path "~/dev/emacs2/modes/jdee-2.4.1/lisp")

;; (autoload 'java-mode "jde" "Emacs Java Development Environment." t)
(add-hook 'java-mode-hook
          (lambda ()
            (setq c-basic-offset 2
                  tab-width 2
                  indent-tabs-mode t)))
