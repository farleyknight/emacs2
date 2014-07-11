(defface extra-whitespace-face
  '((t (:background "pale green")))
  "Used for tabs and such.")

(defvar my-extra-keywords
  '(("\t" . 'extra-whitespace-face)))

(add-hook
 'java-mode-hook
 (lambda ()
   (setq c-basic-offset 2
         tab-width 2)))

(add-hook
 'java-mode-hook
 (lambda ()
   (c-set-offset 'topmost-intro-cont 'c-lineup-cascaded-calls)))

(add-hook
 'java-mode-hook
 (lambda ()
   (c-set-offset 'statement-cont 'c-lineup-cascaded-calls)))

(add-hook
 'java-mode-hook
 (lambda ()
   (font-lock-add-keywords nil my-extra-keywords)))

(setq-default indent-tabs-mode nil)
(setq indent-tabs-mode nil)
