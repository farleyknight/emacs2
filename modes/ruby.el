
;; Ruby mode by file extension
(add-to-list 'auto-mode-alist '("\\.rb$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.thor$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.treetop$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.rake$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.gemspec$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Rakefile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Gemfile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Guardfile$" . ruby-mode))


;; Ugly indent:
;;
;; User.all({
;;        :joins => :account,
;;        :conditions => {:delete_at => nil}
;;      })
;;
;; Pretty indent:
;;
;; User.all({
;;   :joins => :account,
;;   :conditions => {:delete_at => nil}
;; })


(setq ruby-deep-indent-paren nil)