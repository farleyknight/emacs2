;; Turn off startup message
(setq inhibit-startup-message t)

;; Turn "yes or no" into "y or n"
(fset 'yes-or-no-p 'y-or-n-p)

;; Functionality
(load "~/dev/emacs2/functionality/backups")
(load "~/dev/emacs2/functionality/keybindings")
(load "~/dev/emacs2/functionality/indent-buffer")
(load "~/dev/emacs2/functionality/cleanup-file")
(load "~/dev/emacs2/functionality/make-directory-when-missing")


;; Major Modes for Languages
(load "~/dev/emacs2/modes/js")
(load "~/dev/emacs2/modes/ruby")
(load "~/dev/emacs2/modes/php")
(load "~/dev/emacs2/modes/csharp")
(load "~/dev/emacs2/modes/scala")
;; TODO: Java
;; TODO: Haskell
;; TODO: Clojure


;; Major Modes for Templates, Data Formats, etc
(load "~/dev/emacs2/modes/css")
(load "~/dev/emacs2/modes/rhtml")
(load "~/dev/emacs2/modes/markdown")
(load "~/dev/emacs2/modes/yml")
(load "~/dev/emacs2/modes/json")
;; TODO: XML
