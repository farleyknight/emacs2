;; Turn off startup message
(setq inhibit-startup-message t)

;; Turn "yes or no" into "y or n"
(fset 'yes-or-no-p 'y-or-n-p)

;; A bunch of Mac OS X settings
(setq ns-function-modifier 'control)
(setq ns-command-modifier 'meta)


;; Functionality
(load "~/dev/emacs2/functionality/backups")
(load "~/dev/emacs2/functionality/keybindings")
(load "~/dev/emacs2/functionality/indent-buffer")
(load "~/dev/emacs2/functionality/cleanup-file")
(load "~/dev/emacs2/functionality/make-directory-when-missing")
(load "~/dev/emacs2/functionality/cycle-buffer")
(load "~/dev/emacs2/functionality/cycle-buffer-config")
(load "~/dev/emacs2/functionality/align-repeat")
(load "~/dev/emacs2/functionality/tab-width")

;; Directory Tree
(load "~/dev/emacs2/functionality/directory-tree")


;; Major Modes for Languages
(load "~/dev/emacs2/modes/js")
(load "~/dev/emacs2/modes/ruby")
(load "~/dev/emacs2/modes/php")
(load "~/dev/emacs2/modes/csharp")
(load "~/dev/emacs2/modes/scala")
(load "~/dev/emacs2/modes/java")
(load "~/dev/emacs2/modes/clojure")
;; TODO: Haskell


;; Major Modes for Templates, Data Formats, etc
(load "~/dev/emacs2/modes/css")
(load "~/dev/emacs2/modes/rhtml")
(load "~/dev/emacs2/modes/markdown")
(load "~/dev/emacs2/modes/yml")
(load "~/dev/emacs2/modes/json")
;; TODO: XML
