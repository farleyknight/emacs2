;; Set tab-width to 2
(setq-default tab-width 2)
(setq-default indent-tabs-mode nil)
(setq tab-width 2)

;; Delete trailing whitespace
(setq-default show-trailing-whitespace t)
(add-hook 'before-save-hook 'delete-trailing-whitespace)
