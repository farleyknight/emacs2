
;; Indent region
(global-set-key "\C-t" 'indent-region)

;; align-regexp with C-a r
(global-unset-key "\C-a")
(global-set-key "\C-ar" 'align-regexp)

(global-set-key "\C-xr" 'replace-string)

;; This is how it should be on Mac OS X!!
(global-set-key [home] 'beginning-of-line)
(global-set-key [end] 'end-of-line)
