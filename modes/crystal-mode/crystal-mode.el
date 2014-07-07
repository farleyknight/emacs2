;;; crystal-mode.el --- Major mode for editing Crystal files

;; Copyright (C) 1994, 1995, 1996 1997, 1998, 1999, 2000, 2001,
;;   2002,2003, 2004, 2005, 2006, 2007, 2008
;;   Free Software Foundation, Inc.

;; Authors: Yukihiro Matsumoto, Nobuyoshi Nakada
;; URL: http://www.emacswiki.org/cgi-bin/wiki/CrystalMode
;; Created: Fri Feb  4 14:49:13 JST 1994
;; Keywords: languages crystal
;; Version: 0.9

;; This file is not part of GNU Emacs. However, a newer version of
;; crystal-mode is included in recent releases of GNU Emacs (version 23
;; and up), but the new version is not guaranteed to be compatible
;; with older versions of Emacs or XEmacs. This file is the last
;; version that aims to keep this compatibility.

;; You can also get the latest version from the Emacs Lisp Package
;; Archive: http://tromey.com/elpa

;; This file is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; It is distributed in the hope that it will be useful, but WITHOUT
;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
;; or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
;; License for more details.

;; You should have received a copy of the GNU General Public License
;; along with it.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Provides font-locking, indentation support, and navigation for Crystal code.
;;
;; If you're installing manually, you should add this to your .emacs
;; file after putting it on your load path:
;;
;;    (autoload 'crystal-mode "crystal-mode" "Major mode for crystal files" t)
;;    (add-to-list 'auto-mode-alist '("\\.rb$" . crystal-mode))
;;    (add-to-list 'interpreter-mode-alist '("crystal" . crystal-mode))
;;

;;; Code:

(defconst crystal-mode-revision "$Revision$"
  "Crystal mode revision string.")

(defconst crystal-mode-version
  (and (string-match "[0-9.]+" crystal-mode-revision)
       (substring crystal-mode-revision (match-beginning 0) (match-end 0)))
  "Crystal mode version number.")

(defconst crystal-keyword-end-re
  (if (string-match "\\_>" "crystal")
      "\\_>"
    "\\>"))

(defconst crystal-block-beg-keywords
  '("class" "struct" "lib" "module" "def" "if" "unless" "case" "while" "until" "for" "begin" "do")
  "Keywords at the beginning of blocks.")

(defconst crystal-block-beg-re
  (regexp-opt crystal-block-beg-keywords)
  "Regexp to match the beginning of blocks.")

(defconst crystal-non-block-do-re
  (concat (regexp-opt '("while" "until" "for" "rescue") t) crystal-keyword-end-re)
  "Regexp to match")

(defconst crystal-indent-beg-re
  (concat "\\(\\s *" (regexp-opt '("class" "struct" "lib" "module" "def") t) "\\)\\|"
          (regexp-opt '("if" "unless" "case" "while" "until" "for" "begin")))
  "Regexp to match where the indentation gets deeper.")

(defconst crystal-modifier-beg-keywords
  '("if" "unless" "while" "until")
  "Modifiers that are the same as the beginning of blocks.")

(defconst crystal-modifier-beg-re
  (regexp-opt crystal-modifier-beg-keywords)
  "Regexp to match modifiers same as the beginning of blocks.")

(defconst crystal-modifier-re
  (regexp-opt (cons "rescue" crystal-modifier-beg-keywords))
  "Regexp to match modifiers.")

(defconst crystal-block-mid-keywords
  '("then" "else" "elsif" "when" "rescue" "ensure")
  "Keywords where the indentation gets shallower in middle of block statements.")

(defconst crystal-block-mid-re
  (regexp-opt crystal-block-mid-keywords)
  "Regexp to match where the indentation gets shallower in middle of block statements.")

(defconst crystal-block-op-keywords
  '("and" "or" "not")
  "Block operators.")

(defconst crystal-block-hanging-re
  (regexp-opt (append crystal-modifier-beg-keywords crystal-block-op-keywords))
  "Regexp to match hanging block modifiers.")

(defconst crystal-block-end-re "\\_<end\\_>")

(defconst crystal-here-doc-beg-re
  "\\(<\\)<\\(-\\)?\\(\\([a-zA-Z0-9_]+\\)\\|[\"]\\([^\"]+\\)[\"]\\|[']\\([^']+\\)[']\\)")

(defconst crystal-here-doc-end-re
  "^\\([ \t]+\\)?\\(.*\\)\\(.\\)$")

(defun crystal-here-doc-end-match ()
  (concat "^"
          (if (match-string 2) "[ \t]*" nil)
          (regexp-quote
           (or (match-string 4)
               (match-string 5)
               (match-string 6)))))

(defun crystal-here-doc-beg-match ()
  (let ((contents (concat
		   (regexp-quote (concat (match-string 2) (match-string 3)))
		   (if (string= (match-string 3) "_") "\\B" "\\b"))))
    (concat "<<"
            (let ((match (match-string 1)))
              (if (and match (> (length match) 0))
                  (concat "\\(?:-\\([\"']?\\)\\|\\([\"']\\)" (match-string 1) "\\)"
                          contents "\\(\\1\\|\\2\\)")
                (concat "-?\\([\"']\\|\\)" contents "\\1"))))))

(defconst crystal-delimiter
  (concat "[?$/%(){}#\"'`.:]\\|<<\\|\\[\\|\\]\\|\\_<\\("
          crystal-block-beg-re
          "\\)\\_>\\|" crystal-block-end-re
          "\\|^=begin\\|" crystal-here-doc-beg-re)
  )

(defconst crystal-negative
  (concat "^[ \t]*\\(\\(" crystal-block-mid-re "\\)\\>\\|"
          crystal-block-end-re "\\|}\\|\\]\\)")
  "Regexp to match where the indentation gets shallower.")

(defconst crystal-operator-chars "-,.+*/%&|^~=<>:")
(defconst crystal-operator-re (concat "[" crystal-operator-chars "]"))

(defconst crystal-symbol-chars "a-zA-Z0-9_")
(defconst crystal-symbol-re (concat "[" crystal-symbol-chars "]"))

(defvar crystal-mode-abbrev-table nil
  "Abbrev table in use in crystal-mode buffers.")

(define-abbrev-table 'crystal-mode-abbrev-table ())

(defvar crystal-mode-map nil "Keymap used in crystal mode.")

(if crystal-mode-map
    nil
  (setq crystal-mode-map (make-sparse-keymap))
  (define-key crystal-mode-map "{" 'crystal-electric-brace)
  (define-key crystal-mode-map "}" 'crystal-electric-brace)
  (define-key crystal-mode-map "\e\C-a" 'crystal-beginning-of-defun)
  (define-key crystal-mode-map "\e\C-e" 'crystal-end-of-defun)
  (define-key crystal-mode-map "\e\C-b" 'crystal-backward-sexp)
  (define-key crystal-mode-map "\e\C-f" 'crystal-forward-sexp)
  (define-key crystal-mode-map "\e\C-p" 'crystal-beginning-of-block)
  (define-key crystal-mode-map "\e\C-n" 'crystal-end-of-block)
  (define-key crystal-mode-map "\e\C-h" 'crystal-mark-defun)
  (define-key crystal-mode-map "\e\C-q" 'crystal-indent-exp)
  (define-key crystal-mode-map "\t" 'crystal-indent-command)
  (define-key crystal-mode-map "\C-c\C-e" 'crystal-insert-end)
  (define-key crystal-mode-map "\C-j" 'crystal-reindent-then-newline-and-indent)
  (define-key crystal-mode-map "\C-c{" 'crystal-toggle-block)
  (define-key crystal-mode-map "\C-c\C-u" 'uncomment-region))

(defvar crystal-mode-syntax-table nil
  "Syntax table in use in crystal-mode buffers.")

(if crystal-mode-syntax-table
    ()
  (setq crystal-mode-syntax-table (make-syntax-table))
  (modify-syntax-entry ?\' "\"" crystal-mode-syntax-table)
  (modify-syntax-entry ?\" "\"" crystal-mode-syntax-table)
  (modify-syntax-entry ?\` "\"" crystal-mode-syntax-table)
  (modify-syntax-entry ?# "<" crystal-mode-syntax-table)
  (modify-syntax-entry ?\n ">" crystal-mode-syntax-table)
  (modify-syntax-entry ?\\ "\\" crystal-mode-syntax-table)
  (modify-syntax-entry ?$ "." crystal-mode-syntax-table)
  (modify-syntax-entry ?? "_" crystal-mode-syntax-table)
  (modify-syntax-entry ?_ "_" crystal-mode-syntax-table)
  (modify-syntax-entry ?: "_" crystal-mode-syntax-table)
  (modify-syntax-entry ?< "." crystal-mode-syntax-table)
  (modify-syntax-entry ?> "." crystal-mode-syntax-table)
  (modify-syntax-entry ?& "." crystal-mode-syntax-table)
  (modify-syntax-entry ?| "." crystal-mode-syntax-table)
  (modify-syntax-entry ?% "." crystal-mode-syntax-table)
  (modify-syntax-entry ?= "." crystal-mode-syntax-table)
  (modify-syntax-entry ?/ "." crystal-mode-syntax-table)
  (modify-syntax-entry ?+ "." crystal-mode-syntax-table)
  (modify-syntax-entry ?* "." crystal-mode-syntax-table)
  (modify-syntax-entry ?- "." crystal-mode-syntax-table)
  (modify-syntax-entry ?\; "." crystal-mode-syntax-table)
  (modify-syntax-entry ?\( "()" crystal-mode-syntax-table)
  (modify-syntax-entry ?\) ")(" crystal-mode-syntax-table)
  (modify-syntax-entry ?\{ "(}" crystal-mode-syntax-table)
  (modify-syntax-entry ?\} "){" crystal-mode-syntax-table)
  (modify-syntax-entry ?\[ "(]" crystal-mode-syntax-table)
  (modify-syntax-entry ?\] ")[" crystal-mode-syntax-table)
  )

(defcustom crystal-indent-tabs-mode nil
  "*Indentation can insert tabs in crystal mode if this is non-nil."
  :type 'boolean :group 'crystal)
(put 'crystal-indent-tabs-mode 'safe-local-variable 'booleanp)

(defcustom crystal-indent-level 2
  "*Indentation of crystal statements."
  :type 'integer :group 'crystal)
(put 'crystal-indent-level 'safe-local-variable 'integerp)

(defcustom crystal-comment-column 32
  "*Indentation column of comments."
  :type 'integer :group 'crystal)
(put 'crystal-comment-column 'safe-local-variable 'integerp)

(defcustom crystal-deep-arglist t
  "*Deep indent lists in parenthesis when non-nil.
Also ignores spaces after parenthesis when 'space."
  :group 'crystal)
(put 'crystal-deep-arglist 'safe-local-variable 'booleanp)

(defcustom crystal-deep-indent-paren '(?\( ?\[ ?\] t)
  "*Deep indent lists in parenthesis when non-nil. t means continuous line.
Also ignores spaces after parenthesis when 'space."
  :group 'crystal)

(defcustom crystal-deep-indent-paren-style 'space
  "Default deep indent style."
  :options '(t nil space) :group 'crystal)

(defcustom crystal-encoding-map '((shift_jis . cp932) (shift-jis . cp932))
  "Alist to map encoding name from emacs to crystal."
  :group 'crystal)

(defcustom crystal-use-encoding-map t
  "*Use `crystal-encoding-map' to set encoding magic comment if this is non-nil."
  :type 'boolean :group 'crystal)

(defvar crystal-indent-point nil "internal variable")

(eval-when-compile (require 'cl))
(defun crystal-imenu-create-index-in-block (prefix beg end)
  (let ((index-alist '()) (case-fold-search nil)
        name next pos decl sing)
    (goto-char beg)
    (while (re-search-forward "^\\s *\\(\\(class\\s +\\|\\(class\\s *<<\\s *\\)\\|module\\s +\\)\\([^\(<\n ]+\\)\\|\\(def\\|alias\\)\\s +\\([^\(\n ]+\\)\\)" end t)
      (setq sing (match-beginning 3))
      (setq decl (match-string 5))
      (setq next (match-end 0))
      (setq name (or (match-string 4) (match-string 6)))
      (setq pos (match-beginning 0))
      (cond
       ((string= "alias" decl)
        (if prefix (setq name (concat prefix name)))
        (push (cons name pos) index-alist))
       ((string= "def" decl)
        (if prefix
            (setq name
                  (cond
                   ((string-match "^self\." name)
                    (concat (substring prefix 0 -1) (substring name 4)))
                  (t (concat prefix name)))))
        (push (cons name pos) index-alist)
        (crystal-accurate-end-of-block end))
       (t
        (if (string= "self" name)
            (if prefix (setq name (substring prefix 0 -1)))
          (if prefix (setq name (concat (substring prefix 0 -1) "::" name)))
          (push (cons name pos) index-alist))
        (crystal-accurate-end-of-block end)
        (setq beg (point))
        (setq index-alist
              (nconc (crystal-imenu-create-index-in-block
                      (concat name (if sing "." "#"))
                      next beg) index-alist))
        (goto-char beg))))
    index-alist))

(defun crystal-imenu-create-index ()
  (nreverse (crystal-imenu-create-index-in-block nil (point-min) nil)))

(defun crystal-accurate-end-of-block (&optional end)
  (let (state)
    (or end (setq end (point-max)))
    (while (and (setq state (apply 'crystal-parse-partial end state))
                (>= (nth 2 state) 0) (< (point) end)))))

(defun crystal-mode-variables ()
  (set-syntax-table crystal-mode-syntax-table)
  (setq show-trailing-whitespace t)
  (setq local-abbrev-table crystal-mode-abbrev-table)
  (make-local-variable 'indent-line-function)
  (setq indent-line-function 'crystal-indent-line)
  (make-local-variable 'require-final-newline)
  (setq require-final-newline t)
  (make-local-variable 'comment-start)
  (setq comment-start "# ")
  (make-local-variable 'comment-end)
  (setq comment-end "")
  (make-local-variable 'comment-column)
  (setq comment-column crystal-comment-column)
  (make-local-variable 'comment-start-skip)
  (setq comment-start-skip "#+ *")
  (setq indent-tabs-mode crystal-indent-tabs-mode)
  (make-local-variable 'parse-sexp-ignore-comments)
  (setq parse-sexp-ignore-comments t)
  (make-local-variable 'parse-sexp-lookup-properties)
  (setq parse-sexp-lookup-properties t)
  (make-local-variable 'paragraph-start)
  (setq paragraph-start (concat "$\\|" page-delimiter))
  (make-local-variable 'paragraph-separate)
  (setq paragraph-separate paragraph-start)
  (make-local-variable 'paragraph-ignore-fill-prefix)
  (setq paragraph-ignore-fill-prefix t))

(defun crystal-mode-set-encoding ()
  (save-excursion
    (widen)
    (goto-char (point-min))
    (when (re-search-forward "[^\0-\177]" nil t)
      (goto-char (point-min))
      (let ((coding-system
             (or coding-system-for-write
                 buffer-file-coding-system)))
        (if coding-system
            (setq coding-system
                  (or (coding-system-get coding-system 'mime-charset)
                      (coding-system-change-eol-conversion coding-system nil))))
        (setq coding-system
              (if coding-system
                  (symbol-name
                   (or (and crystal-use-encoding-map
                            (cdr (assq coding-system crystal-encoding-map)))
                       coding-system))
                "ascii-8bit"))
        (if (looking-at "^#!") (beginning-of-line 2))
        (cond ((looking-at "\\s *#.*-\*-\\s *\\(en\\)?coding\\s *:\\s *\\([-a-z0-9_]*\\)\\s *\\(;\\|-\*-\\)")
               (unless (string= (match-string 2) coding-system)
                 (goto-char (match-beginning 2))
                 (delete-region (point) (match-end 2))
                 (and (looking-at "-\*-")
                      (let ((n (skip-chars-backward " ")))
                        (cond ((= n 0) (insert "  ") (backward-char))
                              ((= n -1) (insert " "))
                              ((forward-char)))))
                 (insert coding-system)))
              ((looking-at "\\s *#.*coding\\s *[:=]"))
              (t (insert "# -*- coding: " coding-system " -*-\n"))
              )))))

(defun crystal-current-indentation ()
  (save-excursion
    (beginning-of-line)
    (back-to-indentation)
    (current-column)))

(defun crystal-indent-line (&optional flag)
  "Correct indentation of the current crystal line."
  (crystal-indent-to (crystal-calculate-indent)))

(defun crystal-indent-command ()
  (interactive)
  (crystal-indent-line t))

(defun crystal-indent-to (x)
  (if x
      (let (shift top beg)
        (and (< x 0) (error "invalid nest"))
        (setq shift (current-column))
        (beginning-of-line)
        (setq beg (point))
        (back-to-indentation)
        (setq top (current-column))
        (skip-chars-backward " \t")
        (if (>= shift top) (setq shift (- shift top))
          (setq shift 0))
        (if (and (bolp)
                 (= x top))
            (move-to-column (+ x shift))
          (move-to-column top)
          (delete-region beg (point))
          (beginning-of-line)
          (indent-to x)
          (move-to-column (+ x shift))))))

(defun crystal-special-char-p (&optional pnt)
  (setq pnt (or pnt (point)))
  (let ((c (char-before pnt)) (b (and (< (point-min) pnt) (char-before (1- pnt)))))
    (cond ((or (eq c ??) (eq c ?$)))
          ((and (eq c ?:) (or (not b) (eq (char-syntax b) ? ))))
          ((eq c ?\\) (eq b ??)))))

(defun crystal-singleton-class-p ()
  (save-excursion
    (forward-word -1)
    (and (or (bolp) (not (eq (char-before (point)) ?_)))
	      (looking-at "class\\s *<<"))))

(defun crystal-expr-beg (&optional option)
  (save-excursion
    (store-match-data nil)
    (let ((space (skip-chars-backward " \t"))
          (start (point)))
      (cond
       ((bolp) t)
       ((progn
          (forward-char -1)
          (and (looking-at "\\?")
               (or (eq (char-syntax (char-before (point))) ?w)
                   (crystal-special-char-p))))
        nil)
       ((and (eq option 'heredoc) (< space 0))
	(not (progn (goto-char start) (crystal-singleton-class-p))))
       ((or (looking-at crystal-operator-re)
            (looking-at "[\\[({,;]")
            (and (looking-at "[!?]")
                 (or (not (eq option 'modifier))
                     (bolp)
                     (save-excursion (forward-char -1) (looking-at "\\Sw$"))))
            (and (looking-at crystal-symbol-re)
                 (skip-chars-backward crystal-symbol-chars)
                 (cond
                  ((looking-at (regexp-opt
                                (append crystal-block-beg-keywords
                                        crystal-block-op-keywords
                                        crystal-block-mid-keywords)
                                'words))
                   (goto-char (match-end 0))
                   (not (looking-at "\\s_\\|[!?:]")))
                  ((eq option 'expr-qstr)
                   (looking-at "[a-zA-Z][a-zA-z0-9_]* +%[^ \t]"))
                  ((eq option 'expr-re)
                   (looking-at "[a-zA-Z][a-zA-z0-9_]* +/[^ \t]"))
                  (t nil)))))))))

(defun crystal-forward-string (term &optional end no-error expand)
  (let ((n 1) (c (string-to-char term))
        (re (if expand
                (concat "[^\\]\\(\\\\\\\\\\)*\\([" term "]\\|\\(#{\\)\\)")
              (concat "[^\\]\\(\\\\\\\\\\)*[" term "]"))))
    (while (and (re-search-forward re end no-error)
                (if (match-beginning 3)
                    (crystal-forward-string "}{" end no-error nil)
                  (> (setq n (if (eq (char-before (point)) c)
                                     (1- n) (1+ n))) 0)))
      (forward-char -1))
    (cond ((zerop n))
          (no-error nil)
          ((error "unterminated string")))))

(defun crystal-deep-indent-paren-p (c &optional pos)
  (cond ((save-excursion
	   (if pos (goto-char pos))
	   (crystal-expr-beg))
	 nil)
	((listp crystal-deep-indent-paren)
         (let ((deep (assoc c crystal-deep-indent-paren)))
           (cond (deep
                  (or (cdr deep) crystal-deep-indent-paren-style))
                 ((memq c crystal-deep-indent-paren)
                  crystal-deep-indent-paren-style))))
        ((eq c crystal-deep-indent-paren) crystal-deep-indent-paren-style)
        ((eq c ?\( ) crystal-deep-arglist)))

(defun crystal-parse-partial (&optional end in-string nest depth pcol indent)
  (or depth (setq depth 0))
  (or indent (setq indent 0))
  (when (re-search-forward crystal-delimiter end 'move)
    (let ((pnt (point)) w re expand)
      (goto-char (match-beginning 0))
      (cond
       ((and (memq (char-before) '(?@ ?$)) (looking-at "\\sw"))
        (goto-char pnt))

       ;; looking at "
       ((looking-at "[\"`]")            ;skip string
        (cond
         ((and (not (eobp))
               (crystal-forward-string (buffer-substring (point) (1+ (point))) end t t))
          nil)
         (t
          (setq in-string (point))
          (goto-char end))))

       ;; looking at '
       ((looking-at "'")
        (cond
         ((and (not (eobp))
               (re-search-forward "[^\\]\\(\\\\\\\\\\)*'" end t))
          nil)
         (t
          (setq in-string (point))
          (goto-char end))))

       ;; looking at =
       ((looking-at "/=")
        (goto-char pnt))

       ;; looking at /
       ((looking-at "/")
        (cond
         ((and (not (eobp)) (crystal-expr-beg 'expr-re))
          (if (crystal-forward-string "/" end t t)
              nil
            (setq in-string (point))
            (goto-char end)))
         (t
          (goto-char pnt))))

       ;; looking at %
       ((looking-at "%")
        (cond
         ((and (not (eobp))
               (crystal-expr-beg 'expr-qstr)
               (not (looking-at "%="))
               (looking-at "%[QqrxWw]?\\([^a-zA-Z0-9 \t\n]\\)"))
          (goto-char (match-beginning 1))
          (setq expand (not (memq (char-before) '(?q ?w))))
          (setq w (match-string 1))
          (cond
           ((string= w "[") (setq re "]["))
           ((string= w "{") (setq re "}{"))
           ((string= w "(") (setq re ")("))
           ((string= w "<") (setq re "><"))
           ((and expand (string= w "\\"))
            (setq w (concat "\\" w))))
          (unless (cond (re (crystal-forward-string re end t expand))
                        (expand (crystal-forward-string w end t t))
                        (t (re-search-forward
                            (if (string= w "\\")
                                "\\\\[^\\]*\\\\"
                              (concat "[^\\]\\(\\\\\\\\\\)*" w))
                            end t)))
            (setq in-string (point))
            (goto-char end)))
         (t
          (goto-char pnt))))
       ((looking-at "\\?")              ;skip ?char
        (cond
         ((and (crystal-expr-beg)
               (looking-at "?\\(\\\\C-\\|\\\\M-\\)*\\\\?."))
          (goto-char (match-end 0)))
         (t
          (goto-char pnt))))
       ((looking-at "\\$")              ;skip $char
        (goto-char pnt)
        (forward-char 1))

       ((looking-at "#")                ;skip comment
        (forward-line 1)
        (goto-char (point)))

       ((looking-at "fun")              ;skip fun
        (forward-line 1)
        (goto-char (point)))


       ((looking-at "[\\[{(]")
        (let ((deep (crystal-deep-indent-paren-p (char-after))))
          (if (and deep (or (not (eq (char-after) ?\{)) (crystal-expr-beg)))
              (progn
                (and (eq deep 'space) (looking-at ".\\s +[^# \t\n]")
                     (setq pnt (1- (match-end 0))))
                (setq nest (cons (cons (char-after (point)) (point)) nest))
                (setq pcol (cons (cons pnt depth) pcol))
                (setq depth 0))
            (setq nest (cons (cons (char-after (point)) pnt) nest))
            (setq depth (1+ depth))))
        (goto-char pnt)
        )
       ((looking-at "[])}]")
        (if (crystal-deep-indent-paren-p (matching-paren (char-after))
				      (if nest
					  (cdr (nth 0 nest))
					(save-excursion
					  (forward-char)
					  (crystal-backward-sexp)
					  (point))))
            (setq depth (cdr (car pcol)) pcol (cdr pcol))
          (setq depth (1- depth)))
        (setq nest (cdr nest))
        (goto-char pnt))
       ((looking-at crystal-block-end-re)
        (if (or (and (not (bolp))
                     (progn
                       (forward-char -1)
                       (setq w (char-after (point)))
                       (or (eq ?_ w)
                           (eq ?. w))))
                (progn
                  (goto-char pnt)
                  (setq w (char-after (point)))
                  (or (eq ?_ w)
                      (eq ?! w)
                      (eq ?? w))))
            nil
          (setq nest (cdr nest))
          (setq depth (1- depth)))
        (goto-char pnt))
       ((looking-at "def\\s +[^(\n;]*")
        (if (or (bolp)
                (progn
                  (forward-char -1)
                  (not (eq ?_ (char-after (point))))))
            (progn
              (setq nest (cons (cons nil pnt) nest))
              (setq depth (1+ depth))))
        (goto-char (match-end 0)))
       ((looking-at (concat "\\_<\\(" crystal-block-beg-re "\\)\\_>"))
        (and
         (save-match-data
           (or (not (looking-at (concat "do" crystal-keyword-end-re)))
               (save-excursion
                 (back-to-indentation)
                 (not (looking-at crystal-non-block-do-re)))))
         (or (bolp)
             (progn
               (forward-char -1)
               (setq w (char-after (point)))
               (not (or (eq ?_ w)
                        (eq ?. w)))))
         (goto-char pnt)
         (setq w (char-after (point)))
         (not (eq ?_ w))
         (not (eq ?! w))
         (not (eq ?? w))
         (not (eq ?: w))
         (skip-chars-forward " \t")
         (goto-char (match-beginning 0))
         (or (not (looking-at crystal-modifier-re))
             (crystal-expr-beg 'modifier))
         (goto-char pnt)
         (setq nest (cons (cons nil pnt) nest))
         (setq depth (1+ depth)))
        (goto-char pnt))
       ((looking-at ":\\(['\"]\\)")
        (goto-char (match-beginning 1))
        (crystal-forward-string (buffer-substring (match-beginning 1) (match-end 1)) end))
       ((looking-at ":\\([-,.+*/%&|^~<>]=?\\|===?\\|<=>\\|![~=]?\\)")
        (goto-char (match-end 0)))
       ((looking-at ":\\([a-zA-Z_][a-zA-Z_0-9]*[!?=]?\\)?")
        (goto-char (match-end 0)))
       ((or (looking-at "\\.\\.\\.?")
            (looking-at "\\.[0-9]+")
            (looking-at "\\.[a-zA-Z_0-9]+")
            (looking-at "\\."))
        (goto-char (match-end 0)))
       ((looking-at "^=begin")
        (if (re-search-forward "^=end" end t)
            (forward-line 1)
          (setq in-string (match-end 0))
          (goto-char end)))
       ((looking-at "<<")
        (cond
         ((and (crystal-expr-beg 'heredoc)
               (looking-at "<<\\(-\\)?\\(\\([\"'`]\\)\\([^\n]+?\\)\\3\\|\\(?:\\sw\\|\\s_\\)+\\)"))
          (setq re (regexp-quote (or (match-string 4) (match-string 2))))
          (if (match-beginning 1) (setq re (concat "\\s *" re)))
          (let* ((id-end (goto-char (match-end 0)))
                 (line-end-position (save-excursion (end-of-line) (point)))
                 (state (list in-string nest depth pcol indent)))
            ;; parse the rest of the line
            (while (and (> line-end-position (point))
                        (setq state (apply 'crystal-parse-partial
                                           line-end-position state))))
            (setq in-string (car state)
                  nest (nth 1 state)
                  depth (nth 2 state)
                  pcol (nth 3 state)
                  indent (nth 4 state))
            ;; skip heredoc section
            (if (re-search-forward (concat "^" re "$") end 'move)
                (forward-line 1)
              (setq in-string id-end)
              (goto-char end))))
         (t
          (goto-char pnt))))
       ((looking-at "^__END__$")
        (goto-char pnt))
       ((looking-at crystal-here-doc-beg-re)
        (if (re-search-forward (crystal-here-doc-end-match)
                               crystal-indent-point t)
            (forward-line 1)
          (setq in-string (match-end 0))
          (goto-char crystal-indent-point)))
       (t
        (error (format "bad string %s"
                       (buffer-substring (point) pnt)
                       ))))))
  (list in-string nest depth pcol))

(defun crystal-parse-region (start end)
  (let (state)
    (save-excursion
      (if start
          (goto-char start)
        (crystal-beginning-of-indent))
      (save-restriction
        (narrow-to-region (point) end)
        (while (and (> end (point))
                    (setq state (apply 'crystal-parse-partial end state))))))
    (list (nth 0 state)                 ; in-string
          (car (nth 1 state))           ; nest
          (nth 2 state)                 ; depth
          (car (car (nth 3 state)))     ; pcol
          ;(car (nth 5 state))          ; indent
          )))

(defun crystal-indent-size (pos nest)
  (+ pos (* (or nest 1) crystal-indent-level)))

(defun crystal-calculate-indent (&optional parse-start)
  (save-excursion
    (beginning-of-line)
    (let ((crystal-indent-point (point))
          (case-fold-search nil)
          state bol eol begin op-end
          (paren (progn (skip-syntax-forward " ")
                        (and (char-after) (matching-paren (char-after)))))
          (indent 0))
      (if parse-start
          (goto-char parse-start)
        (crystal-beginning-of-indent)
        (setq parse-start (point)))
      (back-to-indentation)
      (setq indent (current-column))
      (setq state (crystal-parse-region parse-start crystal-indent-point))
      (cond
       ((nth 0 state)                   ; within string
        (setq indent nil))              ;  do nothing
       ((car (nth 1 state))             ; in paren
        (goto-char (setq begin (cdr (nth 1 state))))
        (let ((deep (crystal-deep-indent-paren-p (car (nth 1 state))
					      (1- (cdr (nth 1 state))))))
          (if deep
              (cond ((and (eq deep t) (eq (car (nth 1 state)) paren))
                     (skip-syntax-backward " ")
                     (setq indent (1- (current-column))))
		    ((eq deep 'space)
		     (goto-char (cdr (nth 1 state)))
		     (setq indent (1+ (current-column))))
                    ((let ((s (crystal-parse-region (point) crystal-indent-point)))
                       (and (nth 2 s) (> (nth 2 s) 0)
                            (or (goto-char (cdr (nth 1 s))) t)))
                     (forward-word -1)
                     (setq indent (crystal-indent-size (current-column) (nth 2 state))))
                    (t
                     (setq indent (current-column))
                     (cond ((eq deep 'space))
                           (paren (setq indent (1- indent)))
                           (t (setq indent (crystal-indent-size (1- indent) 1))))))
            (if (nth 3 state) (goto-char (nth 3 state))
              (goto-char parse-start) (back-to-indentation))
            (setq indent (crystal-indent-size (current-column) (nth 2 state))))
          (and (eq (car (nth 1 state)) paren)
               (crystal-deep-indent-paren-p (matching-paren paren)
					 (1- (cdr (nth 1 state))))
               (search-backward (char-to-string paren))
               (setq indent (current-column)))))
       ((and (nth 2 state) (> (nth 2 state) 0)) ; in nest
        (if (null (cdr (nth 1 state)))
            (error "invalid nest"))
        (goto-char (cdr (nth 1 state)))
        (forward-word -1)               ; skip back a keyword
        (setq begin (point))
        (cond
         ((looking-at "do\\>[^_]")      ; iter block is a special case
          (if (nth 3 state) (goto-char (nth 3 state))
            (goto-char parse-start) (back-to-indentation))
          (setq indent (crystal-indent-size (current-column) (nth 2 state))))
         (t
          (setq indent (+ (current-column) crystal-indent-level)))))

       ((and (nth 2 state) (< (nth 2 state) 0)) ; in negative nest
        (setq indent (crystal-indent-size (current-column) (nth 2 state)))))
      (when indent
        (goto-char crystal-indent-point)
        (end-of-line)
        (setq eol (point))
        (beginning-of-line)
        (cond
         ((and (not (crystal-deep-indent-paren-p paren
					      (and (cdr (nth 1 state))
						   (1- (cdr (nth 1 state))))))
               (re-search-forward crystal-negative eol t))
          (and (not (eq ?_ (char-after (match-end 0))))
               (setq indent (- indent crystal-indent-level))))
         ((and
           (save-excursion
             (beginning-of-line)
             (not (bobp)))
           (or (crystal-deep-indent-paren-p t)
               (null (car (nth 1 state)))))
          ;; goto beginning of non-empty no-comment line
          (let (end done)
            (while (not done)
              (skip-chars-backward " \t\n")
              (setq end (point))
              (beginning-of-line)
              (if (re-search-forward "^\\s *#" end t)
                  (beginning-of-line)
                (setq done t))))
          (setq bol (point))
          (end-of-line)
          ;; skip the comment at the end
          (skip-chars-backward " \t")
          (let (end (pos (point)))
            (beginning-of-line)
            (while (and (re-search-forward "#" pos t)
                        (setq end (1- (point)))
                        (or (crystal-special-char-p end)
                            (and (setq state (crystal-parse-region parse-start end))
                                 (nth 0 state))))
              (setq end nil))
            (goto-char (or end pos))
            (skip-chars-backward " \t")
            (setq begin (if (and end (nth 0 state)) pos (cdr (nth 1 state))))
            (setq state (crystal-parse-region parse-start (point))))
          (or (bobp) (forward-char -1))
          (and
           (or (and (looking-at crystal-symbol-re)
                    (skip-chars-backward crystal-symbol-chars)
                    (looking-at (concat "\\<\\(" crystal-block-hanging-re "\\)\\>"))
                    (not (eq (point) (nth 3 state)))
                    (save-excursion
                      (goto-char (match-end 0))
                      (not (looking-at "[a-z_]"))))
               (and (looking-at crystal-operator-re)
                    (not (crystal-special-char-p))
                    ;; operator at the end of line
                    (let ((c (char-after (point))))
                      (and
;;                     (or (null begin)
;;                         (save-excursion
;;                           (goto-char begin)
;;                           (skip-chars-forward " \t")
;;                           (not (or (eolp) (looking-at "#")
;;                                    (and (eq (car (nth 1 state)) ?{)
;;                                         (looking-at "|"))))))
                       (or (not (eq ?/ c))
                           (null (nth 0 (crystal-parse-region (or begin parse-start) (point)))))
                       (or (not (eq ?| (char-after (point))))
                           (save-excursion
                             (or (eolp) (forward-char -1))
                             (cond
                              ((search-backward "|" nil t)
                               (skip-chars-backward " \t\n")
                               (and (not (eolp))
                                    (progn
                                      (forward-char -1)
                                      (not (looking-at "{")))
                                    (progn
                                      (forward-word -1)
                                      (not (looking-at "do\\>[^_]")))))
                              (t t))))
                       (not (eq ?, c))
                       (setq op-end t)))))
           (setq indent
                 (cond
                  ((and
                    (null op-end)
                    (not (looking-at (concat "\\<\\(" crystal-block-hanging-re "\\)\\>")))
                    (eq (crystal-deep-indent-paren-p t) 'space)
                    (not (bobp)))
                   (widen)
                   (goto-char (or begin parse-start))
                   (skip-syntax-forward " ")
                   (current-column))
                  ((car (nth 1 state)) indent)
                  (t
                   (+ indent crystal-indent-level))))))))
      (goto-char crystal-indent-point)
      (beginning-of-line)
      (skip-syntax-forward " ")
      (if (looking-at "\\.[^.]")
          (+ indent crystal-indent-level)
        indent))))

(defun crystal-electric-brace (arg)
  (interactive "P")
  (insert-char last-command-event 1)
  (crystal-indent-line t)
  (delete-char -1)
  (self-insert-command (prefix-numeric-value arg)))

(eval-when-compile
  (defmacro defun-region-command (func args &rest body)
    (let ((intr (car body)))
      (when (featurep 'xemacs)
        (if (stringp intr) (setq intr (cadr body)))
        (and (eq (car intr) 'interactive)
             (setq intr (cdr intr))
             (setcar intr (concat "_" (car intr)))))
      (cons 'defun (cons func (cons args body))))))

(defun-region-command crystal-beginning-of-defun (&optional arg)
  "Move backward to next beginning-of-defun.
With argument, do this that many times.
Returns t unless search stops due to end of buffer."
  (interactive "p")
  (and (re-search-backward (concat "^\\(" crystal-block-beg-re "\\)\\_>")
                           nil 'move (or arg 1))
       (progn (beginning-of-line) t)))

(defun crystal-beginning-of-indent ()
  (and (re-search-backward (concat "^\\(" crystal-indent-beg-re "\\)\\_>")
                           nil 'move)
       (progn
         (beginning-of-line)
         t)))

(defun-region-command crystal-end-of-defun (&optional arg)
  "Move forward to next end of defun.
An end of a defun is found by moving forward from the beginning of one."
  (interactive "p")
  (and (re-search-forward (concat "^\\(" crystal-block-end-re "\\)\\($\\|\\b[^_]\\)")
                          nil 'move (or arg 1))
       (progn (beginning-of-line) t))
  (forward-line 1))

(defun crystal-move-to-block (n)
  (let (start pos done down (orig (point)))
    (setq start (crystal-calculate-indent))
    (setq down (looking-at (if (< n 0) crystal-block-end-re
                             (concat "\\<\\(" crystal-block-beg-re "\\)\\>"))))
    (while (and (not done) (not (if (< n 0) (bobp) (eobp))))
      (forward-line n)
      (cond
       ((looking-at "^\\s *$"))
       ((looking-at "^\\s *#"))
       ((and (> n 0) (looking-at "^=begin\\>"))
        (re-search-forward "^=end\\>"))
       ((and (< n 0) (looking-at "^=end\\>"))
        (re-search-backward "^=begin\\>"))
       (t
        (setq pos (current-indentation))
        (cond
         ((< start pos)
          (setq down t))
         ((and down (= pos start))
          (setq done t))
         ((> start pos)
          (setq done t)))))
      (if done
          (save-excursion
            (back-to-indentation)
            (if (looking-at (concat "\\<\\(" crystal-block-mid-re "\\)\\>"))
                (setq done nil)))))
    (back-to-indentation)
    (when (< n 0)
      (let ((eol (point-at-eol)) state next)
	(if (< orig eol) (setq eol orig))
	(setq orig (point))
	(while (and (setq next (apply 'crystal-parse-partial eol state))
		    (< (point) eol))
	  (setq state next))
	(when (cdaadr state)
	  (goto-char (cdaadr state)))
	(backward-word)))))

(defun-region-command crystal-beginning-of-block (&optional arg)
  "Move backward to next beginning-of-block"
  (interactive "p")
  (crystal-move-to-block (- (or arg 1))))

(defun-region-command crystal-end-of-block (&optional arg)
  "Move forward to next beginning-of-block"
  (interactive "p")
  (crystal-move-to-block (or arg 1)))

(defun-region-command crystal-forward-sexp (&optional cnt)
  (interactive "p")
  (if (and (numberp cnt) (< cnt 0))
      (crystal-backward-sexp (- cnt))
    (let ((i (or cnt 1)))
      (condition-case nil
          (while (> i 0)
            (skip-syntax-forward " ")
            (if (looking-at ",\\s *") (goto-char (match-end 0)))
            (cond ((looking-at "\\?\\(\\\\[CM]-\\)*\\\\?\\S ")
                   (goto-char (match-end 0)))
                  ((progn
                     (skip-chars-forward ",.:;|&^~=!?\\+\\-\\*")
                     (looking-at "\\s("))
                   (goto-char (scan-sexps (point) 1)))
                  ((and (looking-at (concat "\\<\\(" crystal-block-beg-re "\\)\\>"))
                        (not (eq (char-before (point)) ?.))
                        (not (eq (char-before (point)) ?:)))
                   (crystal-end-of-block)
                   (forward-word 1))
                  ((looking-at "\\(\\$\\|@@?\\)?\\sw")
                   (while (progn
                            (while (progn (forward-word 1) (looking-at "_")))
                            (cond ((looking-at "::") (forward-char 2) t)
                                  ((> (skip-chars-forward ".") 0))
                                  ((looking-at "\\?\\|!\\(=[~=>]\\|[^~=]\\)")
                                   (forward-char 1) nil)))))
                  ((let (state expr)
                     (while
                         (progn
                           (setq expr (or expr (crystal-expr-beg)
                                          (looking-at "%\\sw?\\Sw\\|[\"'`/]")))
                           (nth 1 (setq state (apply 'crystal-parse-partial nil state))))
                       (setq expr t)
                       (skip-chars-forward "<"))
                     (not expr))))
            (setq i (1- i)))
        ((error) (forward-word 1)))
      i)))

(defun-region-command crystal-backward-sexp (&optional cnt)
  (interactive "p")
  (if (and (numberp cnt) (< cnt 0))
      (crystal-forward-sexp (- cnt))
    (let ((i (or cnt 1)))
      (condition-case nil
          (while (> i 0)
            (skip-chars-backward " \t\n,.:;|&^~=!?\\+\\-\\*")
            (forward-char -1)
            (cond ((looking-at "\\s)")
                   (goto-char (scan-sexps (1+ (point)) -1))
                   (case (char-before)
                     (?% (forward-char -1))
                     ('(?q ?Q ?w ?W ?r ?x)
                      (if (eq (char-before (1- (point))) ?%) (forward-char -2))))
                   nil)
                  ((looking-at "\\s\"\\|\\\\\\S_")
                   (let ((c (char-to-string (char-before (match-end 0)))))
                     (while (and (search-backward c)
                                 (oddp (skip-chars-backward "\\")))))
                   nil)
                  ((looking-at "\\s.\\|\\s\\")
                   (if (crystal-special-char-p) (forward-char -1)))
                  ((looking-at "\\s(") nil)
                  (t
                   (forward-char 1)
                   (while (progn (forward-word -1)
                                 (case (char-before)
                                   (?_ t)
                                   (?. (forward-char -1) t)
                                   ((?$ ?@)
                                    (forward-char -1)
                                    (and (eq (char-before) (char-after)) (forward-char -1)))
                                   (?:
                                    (forward-char -1)
                                    (eq (char-before) :)))))
                   (if (looking-at crystal-block-end-re)
                       (crystal-beginning-of-block))
                   nil))
            (setq i (1- i)))
        ((error)))
      i)))

(defun crystal-reindent-then-newline-and-indent ()
  (interactive "*")
  (newline)
  (save-excursion
    (end-of-line 0)
    (indent-according-to-mode)
    (delete-region (point) (progn (skip-chars-backward " \t") (point))))
  (indent-according-to-mode))

(fset 'crystal-encomment-region (symbol-function 'comment-region))

(defun crystal-decomment-region (beg end)
  (interactive "r")
  (save-excursion
    (goto-char beg)
    (while (re-search-forward "^\\([ \t]*\\)#" end t)
      (replace-match "\\1" nil nil)
      (save-excursion
        (crystal-indent-line)))))

(defun crystal-insert-end ()
  (interactive)
  (insert "end")
  (crystal-indent-line t)
  (end-of-line))

(defun crystal-mark-defun ()
  "Put mark at end of this Crystal function, point at beginning."
  (interactive)
  (push-mark (point))
  (crystal-end-of-defun)
  (push-mark (point) nil t)
  (crystal-beginning-of-defun)
  (re-search-backward "^\n" (- (point) 1) t))

(defun crystal-indent-exp (&optional shutup-p)
  "Indent each line in the balanced expression following point syntactically.
If optional SHUTUP-P is non-nil, no errors are signalled if no
balanced expression is found."
  (interactive "*P")
  (let ((here (point-marker)) start top column (nest t))
    (set-marker-insertion-type here t)
    (unwind-protect
        (progn
          (beginning-of-line)
          (setq start (point) top (current-indentation))
          (while (and (not (eobp))
                      (progn
                        (setq column (crystal-calculate-indent start))
                        (cond ((> column top)
                               (setq nest t))
                              ((and (= column top) nest)
                               (setq nest nil) t))))
            (crystal-indent-to column)
            (beginning-of-line 2)))
      (goto-char here)
      (set-marker here nil))))

(defun crystal-add-log-current-method ()
  "Return current method string."
  (condition-case nil
      (save-excursion
        (let (mname mlist (indent 0))
          ;; get current method (or class/module)
          (if (re-search-backward
               (concat "^[ \t]*\\(def\\|class\\|module\\)[ \t]+"
                       "\\("
                       ;; \\. and :: for class method
                        "\\([A-Za-z_]" crystal-symbol-re "*\\|\\.\\|::" "\\)"
                        "+\\)")
               nil t)
              (progn
                (setq mname (match-string 2))
                (unless (string-equal "def" (match-string 1))
                  (setq mlist (list mname) mname nil))
                (goto-char (match-beginning 1))
                (setq indent (current-column))
                (beginning-of-line)))
          ;; nest class/module
          (while (and (> indent 0)
                      (re-search-backward
                       (concat
                        "^[ \t]*\\(class\\|module\\)[ \t]+"
                        "\\([A-Z]" crystal-symbol-re "*\\)")
                       nil t))
            (goto-char (match-beginning 1))
            (if (< (current-column) indent)
                (progn
                  (setq mlist (cons (match-string 2) mlist))
                  (setq indent (current-column))
                  (beginning-of-line))))
          (when mname
            (let ((mn (split-string mname "\\.\\|::")))
              (if (cdr mn)
                  (progn
                    (cond
                     ((string-equal "" (car mn))
                      (setq mn (cdr mn) mlist nil))
                     ((string-equal "self" (car mn))
                      (setq mn (cdr mn)))
                     ((let ((ml (nreverse mlist)))
                        (while ml
                          (if (string-equal (car ml) (car mn))
                              (setq mlist (nreverse (cdr ml)) ml nil))
                          (or (setq ml (cdr ml)) (nreverse mlist))))))
                    (if mlist
                        (setcdr (last mlist) mn)
                      (setq mlist mn))
                    (setq mn (last mn 2))
                    (setq mname (concat "." (cadr mn)))
                    (setcdr mn nil))
                (setq mname (concat "#" mname)))))
          ;; generate string
          (if (consp mlist)
              (setq mlist (mapconcat (function identity) mlist "::")))
          (if mname
              (if mlist (concat mlist mname) mname)
            mlist)))))

(defun crystal-brace-to-do-end ()
  (when (looking-at "{")
    (let ((orig (point)) (end (progn (crystal-forward-sexp) (point))))
      (when (eq (char-before) ?\})
	(delete-char -1)
	(if (eq (char-syntax (char-before)) ?w)
	    (insert " "))
	(insert "end")
	(if (eq (char-syntax (char-after)) ?w)
	    (insert " "))
	(goto-char orig)
	(delete-char 1)
	(if (eq (char-syntax (char-before)) ?w)
	    (insert " "))
	(insert "do")
	(when (looking-at "\\sw\\||")
	  (insert " ")
	  (backward-char))
	t))))

(defun crystal-do-end-to-brace ()
  (when (and (or (bolp)
		 (not (memq (char-syntax (char-before)) '(?w ?_))))
	     (looking-at "\\<do\\(\\s \\|$\\)"))
    (let ((orig (point)) (end (progn (crystal-forward-sexp) (point))))
      (backward-char 3)
      (when (looking-at crystal-block-end-re)
	(delete-char 3)
	(insert "}")
	(goto-char orig)
	(delete-char 2)
	(insert "{")
	(if (looking-at "\\s +|")
	    (delete-char (- (match-end 0) (match-beginning 0) 1)))
	t))))

(defun crystal-toggle-block ()
  (interactive)
  (or (crystal-brace-to-do-end)
      (crystal-do-end-to-brace)))

(eval-when-compile
  (if (featurep 'font-lock)
      (defmacro eval-when-font-lock-available (&rest args) (cons 'progn args))
    (defmacro eval-when-font-lock-available (&rest args))))

(eval-when-compile
  (if (featurep 'hilit19)
      (defmacro eval-when-hilit19-available (&rest args) (cons 'progn args))
    (defmacro eval-when-hilit19-available (&rest args))))

(eval-when-font-lock-available
  (or (boundp 'font-lock-variable-name-face)
      (setq font-lock-variable-name-face font-lock-type-face))

  (defconst crystal-font-lock-syntactic-keywords
        `(
          ;; #{ }, #$hoge, #@foo are not comments
          ("\\(#\\)[{$@]" 1 (1 . nil))
          ;; the last $', $", $` in the respective string is not variable
          ;; the last ?', ?", ?` in the respective string is not ascii code
          ("\\(^\\|[\[ \t\n<+\(,=]\\)\\(['\"`]\\)\\(\\\\.\\|\\2\\|[^'\"`\n\\\\]\\)*?\\\\?[?$]\\(\\2\\)"
           (2 (7 . nil))
           (4 (7 . nil)))
          ;; $' $" $` .... are variables
          ;; ?' ?" ?` are ascii codes
          ("\\(^\\|[^\\\\]\\)\\(\\\\\\\\\\)*[?$]\\([#\"'`]\\)" 3 (1 . nil))
          ;; regexps
          ("\\(^\\|[[=(,~?:;<>]\\|\\(^\\|\\s \\)\\(if\\|elsif\\|unless\\|while\\|until\\|when\\|and\\|or\\|&&\\|||\\)\\|g?sub!?\\|scan\\|split!?\\)\\s *\\(/\\)[^/\n\\\\]*\\(\\\\.[^/\n\\\\]*\\)*\\(/\\)"
           (4 (7 . ?/))
           (6 (7 . ?/)))
          ("^\\(=\\)begin\\(\\s \\|$\\)" 1 (7 . nil))
          ("^\\(=\\)end\\(\\s \\|$\\)" 1 (7 . nil))
          (,(concat crystal-here-doc-beg-re ".*\\(\n\\)")
           ,(+ 1 (regexp-opt-depth crystal-here-doc-beg-re))
           (crystal-here-doc-beg-syntax))
          (,crystal-here-doc-end-re 3 (crystal-here-doc-end-syntax))))

  (unless (functionp 'syntax-ppss)
    (defun syntax-ppss (&optional pos)
      (parse-partial-sexp (point-min) (or pos (point)))))

  (defun crystal-in-ppss-context-p (context &optional ppss)
    (let ((ppss (or ppss (syntax-ppss (point)))))
      (if (cond
           ((eq context 'anything)
            (or (nth 3 ppss)
                (nth 4 ppss)))
           ((eq context 'string)
            (nth 3 ppss))
           ((eq context 'heredoc)
            (and (nth 3 ppss)
                 ;; If it's generic string, it's a heredoc and we don't care
                 ;; See `parse-partial-sexp'
                 (not (numberp (nth 3 ppss)))))
           ((eq context 'non-heredoc)
            (and (crystal-in-ppss-context-p 'anything)
                 (not (crystal-in-ppss-context-p 'heredoc))))
           ((eq context 'comment)
            (nth 4 ppss))
           (t
            (error (concat
                    "Internal error on `crystal-in-ppss-context-p': "
                    "context name `" (symbol-name context) "' is unknown"))))
          t)))

  (defun crystal-in-here-doc-p ()
    (save-excursion
      (let ((old-point (point)) (case-fold-search nil))
        (beginning-of-line)
        (catch 'found-beg
          (while (and (re-search-backward crystal-here-doc-beg-re nil t)
		      (not (crystal-singleton-class-p)))
            (if (not (or (crystal-in-ppss-context-p 'anything)
                         (crystal-here-doc-find-end old-point)))
                (throw 'found-beg t)))))))

  (defun crystal-here-doc-find-end (&optional limit)
    "Expects the point to be on a line with one or more heredoc
openers. Returns the buffer position at which all heredocs on the
line are terminated, or nil if they aren't terminated before the
buffer position `limit' or the end of the buffer."
    (save-excursion
      (beginning-of-line)
      (catch 'done
        (let ((eol (save-excursion (end-of-line) (point)))
              (case-fold-search nil)
              ;; Fake match data such that (match-end 0) is at eol
              (end-match-data (progn (looking-at ".*$") (match-data)))
              beg-match-data end-re)
          (while (re-search-forward crystal-here-doc-beg-re eol t)
            (setq beg-match-data (match-data))
            (setq end-re (crystal-here-doc-end-match))

            (set-match-data end-match-data)
            (goto-char (match-end 0))
            (unless (re-search-forward end-re limit t) (throw 'done nil))
            (setq end-match-data (match-data))

            (set-match-data beg-match-data)
            (goto-char (match-end 0)))
          (set-match-data end-match-data)
          (goto-char (match-end 0))
          (point)))))

  (defun crystal-here-doc-beg-syntax ()
    (save-excursion
      (goto-char (match-beginning 0))
      (unless (or (crystal-in-ppss-context-p 'non-heredoc)
                  (crystal-in-here-doc-p))
        (string-to-syntax "|"))))

  (defun crystal-here-doc-end-syntax ()
    (let ((pss (syntax-ppss)) (case-fold-search nil))
      (when (crystal-in-ppss-context-p 'heredoc pss)
        (save-excursion
          (goto-char (nth 8 pss))     ; Go to the beginning of heredoc.
          (let ((eol (point)))
            (beginning-of-line)
            (if (and (re-search-forward (crystal-here-doc-beg-match) eol t) ; If there is a heredoc that matches this line...
                     (not (crystal-in-ppss-context-p 'anything)) ; And that's not inside a heredoc/string/comment...
                     (progn (goto-char (match-end 0)) ; And it's the last heredoc on its line...
                            (not (re-search-forward crystal-here-doc-beg-re eol t))))
                (string-to-syntax "|")))))))

  (eval-when-compile
      (put 'crystal-mode 'font-lock-defaults
           '((crystal-font-lock-keywords)
             nil nil nil
             beginning-of-line
             (font-lock-syntactic-keywords
              . crystal-font-lock-syntactic-keywords))))

  (defun crystal-font-lock-docs (limit)
    (if (re-search-forward "^=begin\\(\\s \\|$\\)" limit t)
        (let (beg)
          (beginning-of-line)
          (setq beg (point))
          (forward-line 1)
          (if (re-search-forward "^=end\\(\\s \\|$\\)" limit t)
              (progn
                (set-match-data (list beg (point)))
                t)))))

  (defun crystal-font-lock-maybe-docs (limit)
    (let (beg)
      (save-excursion
        (if (and (re-search-backward "^=\\(begin\\|end\\)\\(\\s \\|$\\)" nil t)
                 (string= (match-string 1) "begin"))
            (progn
              (beginning-of-line)
              (setq beg (point)))))
      (if (and beg (and (re-search-forward "^=\\(begin\\|end\\)\\(\\s \\|$\\)" nil t)
                        (string= (match-string 1) "end")))
          (progn
            (set-match-data (list beg (point)))
            t)
        nil)))

  (defvar crystal-font-lock-syntax-table
    (let* ((tbl (copy-syntax-table crystal-mode-syntax-table)))
      (modify-syntax-entry ?_ "w" tbl)
      tbl))

  (defconst crystal-font-lock-keywords
    (list
     ;; functions
     '("^\\s *def\\s +\\([^( \t\n]+\\)"
       1 font-lock-function-name-face)
     ;; keywords
     (cons (concat
            "\\(^\\|[^_:.@$]\\|\\.\\.\\)\\_<\\(defined\\?\\|"
            (regexp-opt
             '("alias"
               "and"
               "begin"
               "break"
               "case"
               "catch"
               "class"
               "def"
               "do"
               "elsif"
               "else"
               "fail"
               "fun"
               "ensure"
               "for"
               "end"
               "if"
               "in"
               "lib"
               "module"
               "next"
               "not"
               "or"
               "raise"
               "redo"
               "rescue"
               "retry"
               "return"
               "then"
               "throw"
               "struct"
               "super"
               "unless"
               "undef"
               "until"
               "when"
               "while"
               "yield"
               )
             t)
            "\\)"
            crystal-keyword-end-re)
           2)
     ;; here-doc beginnings
     (list crystal-here-doc-beg-re 0 'font-lock-string-face)
     ;; variables
     '("\\(^\\|[^_:.@$]\\|\\.\\.\\)\\_<\\(nil\\|self\\|true\\|false\\)\\>"
       2 font-lock-variable-name-face)
     ;; variables
     '("\\(\\$\\([^a-zA-Z0-9 \n]\\|[0-9]\\)\\)\\W"
       1 font-lock-variable-name-face)
     '("\\(\\$\\|@\\|@@\\)\\(\\w\\|_\\)+"
       0 font-lock-variable-name-face)
     ;; embedded document
     '(crystal-font-lock-docs
       0 font-lock-comment-face t)
     '(crystal-font-lock-maybe-docs
       0 font-lock-comment-face t)
     ;; general delimited string
     '("\\(^\\|[[ \t\n<+(,=]\\)\\(%[xrqQwW]?\\([^<[{(a-zA-Z0-9 \n]\\)[^\n\\\\]*\\(\\\\.[^\n\\\\]*\\)*\\(\\3\\)\\)"
       (2 font-lock-string-face))
     ;; constants
     '("\\(^\\|[^_]\\)\\_<\\([A-Z]+\\(\\w\\|_\\)*\\)"
       2 font-lock-type-face)
     ;; symbols
     '("\\(^\\|[^:]\\)\\(:\\([-+~]@?\\|[/%&|^`]\\|\\*\\*?\\|<\\(<\\|=>?\\)?\\|>[>=]?\\|===?\\|=~\\|![~=]?\\|\\[\\]=?\\|\\(\\w\\|_\\)+\\([!?=]\\|\\b_*\\)\\|#{[^}\n\\\\]*\\(\\\\.[^}\n\\\\]*\\)*}\\)\\)"
       2 font-lock-reference-face)
     '("\\(^\\s *\\|[\[\{\(,]\\s *\\|\\sw\\s +\\)\\(\\(\\sw\\|_\\)+\\):[^:]" 2 font-lock-reference-face)
     ;; expression expansion
     '("#\\({[^}\n\\\\]*\\(\\\\.[^}\n\\\\]*\\)*}\\|\\(\\$\\|@\\|@@\\)\\(\\w\\|_\\)+\\)"
       0 font-lock-variable-name-face t)
     ;; warn lower camel case
     ;'("\\<[a-z]+[a-z0-9]*[A-Z][A-Za-z0-9]*\\([!?]?\\|\\>\\)"
     ;  0 font-lock-warning-face)
     )
    "*Additional expressions to highlight in crystal mode."))

(eval-when-hilit19-available
  (hilit-set-mode-patterns
   'crystal-mode
   '(("[^$\\?]\\(\"[^\\\"]*\\(\\\\\\(.\\|\n\\)[^\\\"]*\\)*\"\\)" 1 string)
     ("[^$\\?]\\('[^\\']*\\(\\\\\\(.\\|\n\\)[^\\']*\\)*'\\)" 1 string)
     ("[^$\\?]\\(`[^\\`]*\\(\\\\\\(.\\|\n\\)[^\\`]*\\)*`\\)" 1 string)
     ("^\\s *#.*$" nil comment)
     ("[^$@?\\]\\(#[^$@{\n].*$\\)" 1 comment)
     ("[^a-zA-Z_]\\(\\?\\(\\\\[CM]-\\)*.\\)" 1 string)
     ("^\\s *\\(require\\|load\\).*$" nil include)
     ("^\\s *\\(include\\|alias\\|undef\\|fun\\).*$" nil decl)
     ("^\\s *\\<\\(class\\|def\\|module\\|struct\\|lib\\)\\>" "[)\n;]" defun)
     ("[^_]\\<\\(begin\\|case\\|else\\|elsif\\|end\\|ensure\\|for\\|if\\|unless\\|rescue\\|then\\|when\\|while\\|until\\|do\\|yield\\)\\>\\([^_]\\|$\\)" 1 defun)
     ("[^_]\\<\\(and\\|break\\|next\\|raise\\|fail\\|in\\|not\\|or\\|redo\\|retry\\|return\\|super\\|yield\\|catch\\|throw\\|self\\|nil\\)\\>\\([^_]\\|$\\)" 1 keyword)
     ("\\$\\(.\\|\\sw+\\)" nil type)
     ("[$@].[a-zA-Z_0-9]*" nil struct)
     ("^__END__" nil label))))


;;;###autoload
(defun crystal-mode ()
  "Major mode for editing crystal scripts.
\\[crystal-indent-command] properly indents subexpressions of multi-line
class, module, def, if, while, for, do, and case statements, taking
nesting into account.

The variable crystal-indent-level controls the amount of indentation.
\\{crystal-mode-map}"
  (interactive)
  (kill-all-local-variables)
  (use-local-map crystal-mode-map)
  (setq mode-name "Crystal")
  (setq major-mode 'crystal-mode)
  (crystal-mode-variables)

  (make-local-variable 'imenu-create-index-function)
  (setq imenu-create-index-function 'crystal-imenu-create-index)

  (make-local-variable 'add-log-current-defun-function)
  (setq add-log-current-defun-function 'crystal-add-log-current-method)

  (add-hook
   (cond ((boundp 'before-save-hook)
          (make-local-variable 'before-save-hook)
          'before-save-hook)
         ((boundp 'write-contents-functions) 'write-contents-functions)
         ((boundp 'write-contents-hooks) 'write-contents-hooks))
   'crystal-mode-set-encoding)

  (set (make-local-variable 'font-lock-defaults) '((crystal-font-lock-keywords) nil nil))
  (set (make-local-variable 'font-lock-keywords) crystal-font-lock-keywords)
  (set (make-local-variable 'font-lock-syntax-table) crystal-font-lock-syntax-table)
  (set (make-local-variable 'font-lock-syntactic-keywords) crystal-font-lock-syntactic-keywords)

  (if (fboundp 'run-mode-hooks)
      (run-mode-hooks 'crystal-mode-hook)
    (run-hooks 'crystal-mode-hook)))

(provide 'crystal-mode)
