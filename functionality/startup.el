
;; Turn off startup message
(setq inhibit-startup-message t)

;; Turn "yes or no" into "y or n"
(fset 'yes-or-no-p 'y-or-n-p)

;; A bunch of Mac OS X settings
(setq ns-function-modifier 'control)
(setq ns-command-modifier 'meta)

;; Hide toolbar (especially in Emacs GUI)
(if (fboundp 'tool-bar-mode)
    (tool-bar-mode -1))

;; Show cursor as a box in all versions of Emacs
(setq-default cursor-type 'box)
