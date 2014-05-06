
(add-to-list 'load-path "~/dev/emacs2/functionality/color-theme-6.6.0/")

(require 'color-theme)
(eval-after-load "color-theme"
  '(progn
     (color-theme-initialize)
     (color-theme-hober)))
