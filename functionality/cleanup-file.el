;; Set tab-width to 2
(setq-default tab-width 2)
(setq-default indent-tabs-mode nil)
(setq tab-width 2)

(add-hook 'before-save-hook 'delete-trailing-whitespace)
