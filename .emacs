;; Turn off startup message
(setq inhibit-startup-message t)

;; Turn "yes or no" into "y or n"
(fset 'yes-or-no-p 'y-or-n-p)

;; Major Modes (languages, templates, etc)
(load "~/dev/emacs2/modes/css")
(load "~/dev/emacs2/modes/rhtml")
(load "~/dev/emacs2/modes/js")
(load "~/dev/emacs2/modes/ruby")
(load "~/dev/emacs2/modes/yml")
(load "~/dev/emacs2/modes/php")
(load "~/dev/emacs2/modes/markdown")

;; Functionality
(load "~/dev/emacs2/functionality/backups")
(load "~/dev/emacs2/functionality/keybindings")
(load "~/dev/emacs2/functionality/indent-buffer")
(load "~/dev/emacs2/functionality/cleanup-file")
