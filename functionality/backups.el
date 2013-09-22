

;; Found these bits from
;; http://snarfed.org/space/gnu%20emacs%20backup%20files

;; Put autosave files (ie #foo#) in one place, *not*
;; scattered all over the file system!
(defvar autosave-dir (concat "~/.emacs.d/autosaves/"))
(make-directory autosave-dir t)

(defun auto-save-file-name-p (filename)
  (string-match "^#.*#$" (file-name-nondirectory filename)))

(defun make-auto-save-file-name ()
  (concat autosave-dir
	  (if buffer-file-name
	      (concat "#" (file-name-nondirectory buffer-file-name) "#")
	    (expand-file-name
	     (concat "#%" (buffer-name) "#")))))


;; Put backup files (ie foo~) in one place too. (The backup-directory-alist
;; list contains regexp=>directory mappings; filenames matching a regexp are
;; backed up in the corresponding directory. Emacs will mkdir it if necessary.)

(defvar backup-dir (concat "~/.emacs.d/backups/"))
(setq backup-directory-alist (list (cons "." backup-dir)))

;; Custom emacs backup file configuration
(setq backup-by-copying t            ; Don't delink hardlinks
      version-control t              ; Use version numbers on backups
      delete-old-versions t          ; Automatically delete excess backups
      kept-new-versions 20           ; how many of the newest versions to keep
      kept-old-versions 5)           ; and how many of the old
