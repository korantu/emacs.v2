;; Got to LOVE minimalism.
(tool-bar-mode 0)
(menu-bar-mode 0)
(scroll-bar-mode 0)

;; General
(setq tab-width 2)

;; Yes-or-No
(defalias 'yes-or-no-p 'y-or-n-p)

;; No startup screen
(setq inhibit-startup-message t)

;; Highlight current line
(global-hl-line-mode 1)

;; Save history
(savehist-mode 1)
(setq savehist-additional-variables '(kill-ring search-ring regexp-search-ring))
(setq savehist-file "~/.emacs.d/tmp/savehist")

;; No backups (Use git!)
(setq make-backup-files nil)

;; Server
(server-start)

;; make it an editor
(if (file-exists-p "/home/konsl/packages/emacs/bin/emacsclient")
    (setenv "EDITOR" "/home/konsl/packages/emacs/bin/emacsclient")
  (message "emacsclient not configured"))

;;; Melpa use M-x list-packages to get updated list.
(require 'package) ;; You might already have this line
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(package-initialize) ;; You might already have this line

;;; Autocomplete
(if (symbol-function 'ac-config-default)
    (ac-config-default))


;; TRAMP
(setq tramp-default-method "ssh")

;; Eldoc
(add-hook 'emacs-lisp-mode-hook 'turn-on-eldoc-mode)
(add-hook 'lisp-interaction-mode-hook 'turn-on-eldoc-mode)
(add-hook 'ielm-mode-hook 'turn-on-eldoc-mode)


(if (file-exists-p "/home/konsl/github.com/jwiegley/emacs-async")
    (progn
      ;; Helm https://github.com/emacs-helm/helm
      (add-to-list 'load-path "/home/konsl/github.com/jwiegley/emacs-async")
      (add-to-list 'load-path "/home/konsl/github.com/emacs-helm/helm")
      (require 'helm-config)

;;; from helm startup configuration
      (blink-cursor-mode -1)
      (helm-mode 1)
      (define-key global-map [remap find-file] 'helm-find-files)
      (define-key global-map [remap occur] 'helm-occur)
      (define-key global-map [remap list-buffers] 'helm-buffers-list)
      (define-key global-map [remap dabbrev-expand] 'helm-dabbrev)
      (global-set-key (kbd "M-x") 'helm-M-x)
      (unless (boundp 'completion-in-region-function)
	(define-key lisp-interaction-mode-map [remap completion-at-point] 'helm-lisp-completion-at-point)
	(define-key emacs-lisp-mode-map       [remap completion-at-point] 'helm-lisp-completion-at-point))
					;(add-hook 'kill-emacs-hook #'(lambda () (and (file-exists-p "$CONF_FILE") (delete-file "$CONF_FILE"))))

      ;;; Autocomplete with helm https://github.com/yasuyk/ac-helm
      (global-set-key (kbd "C-:") 'ac-complete-with-helm)
      (define-key ac-complete-mode-map (kbd "C-:") 'ac-complete-with-helm)

      )
  (message "Please set up helm"))


;; yasnippet
(require 'yasnippet)
(yas-reload-all)
(yas-global-mode 1)

(add-to-list 'hippie-expand-try-functions-list 'yas-hippie-try-expand)

;; hippie expand
(global-set-key (kbd "<f12>") 'hippie-expand)

;; general keyboard stuff
(global-set-key (kbd "<f12>") 'compile)
(global-set-key (kbd "C-M-)") 'edit-last-kbd-macro)

;; from https://www.emacswiki.org/emacs/Yasnippet
(defun shk-yas/helm-prompt (prompt choices &optional display-fn)
    "Use helm to select a snippet. Put this into `yas-prompt-functions.'"
    (interactive)
    (setq display-fn (or display-fn 'identity))
    (if (require 'helm-config)
        (let (tmpsource cands result rmap)
          (setq cands (mapcar (lambda (x) (funcall display-fn x)) choices))
          (setq rmap (mapcar (lambda (x) (cons (funcall display-fn x) x)) choices))
          (setq tmpsource
                (list
                 (cons 'name prompt)
                 (cons 'candidates cands)
                 '(action . (("Expand" . (lambda (selection) selection))))
                 ))
          (setq result (helm-other-buffer '(tmpsource) "*helm-select-yasnippet"))
          (if (null result)
              (signal 'quit "user quit!")
            (cdr (assoc result rmap))))
      nil))



;;; Modes automatic loading by extension
(add-to-list 'auto-mode-alist '("\\.bash_aliases\\'" . shell-script-mode))

;;; Go-related
;; tweaks

       
(if (and
     (file-exists-p "/home/konsl/source/gopath")
     (file-exists-p "/usr/local/go/bin"))
    (progn 
      (setenv "GOPATH" "/home/konsl/source/gopath")
      (setenv "PATH"
	      (concat "/usr/local/go/bin:/home/konsl/source/gopath/bin:" (getenv "PATH")))
      
      (add-hook 'before-save-hook 'gofmt-before-save)
      
      (defun auto-complete-for-go ()
	(auto-complete-mode 1))
      (add-hook 'go-mode-hook 'auto-complete-for-go)
      
      (with-eval-after-load 'go-mode
	(require 'go-autocomplete))
      
      ;; compile error by running C-x `
      (defun my-go-mode-hook ()
	(setq gofmt-command "goimports")
					; Call Gofmt before saving
	(add-hook 'before-save-hook 'gofmt-before-save)
					; Customize compile command to run go build
	(if (not (string-match "go" compile-command))
	    (set (make-local-variable 'compile-command)
		 "go build -v && go test -v && go vet"))
					; Godef jump key binding
	(local-set-key (kbd "M-.") 'godef-jump))
      
      (add-hook 'go-mode-hook 'my-go-mode-hook)


      ;; Go oracle
      (load-file "$GOPATH/src/golang.org/x/tools/cmd/oracle/oracle.el"))

  ;; Else
  ( message "Please install GO / set up GOPATH to use go"))

;; shell mode

(defun make-executable ()
  "Takes file and makes it executable"
  (interactive)
  (let*
      ((name (buffer-file-name))
       (cmd (concat "chmod +x " name)))
    (if (file-exists-p name)
	(shell-command cmd)
      (message "Can't find %s to chmod" name))))

(defun my-sh-mode-hook ()
  "Things to do in relation to scripting"
  (interactive)
  (message "Adding after-save hook!")
  (add-hook 'after-save-hook 'make-executable))

(add-hook 'sh-mode-hook 'my-sh-mode-hook)

;; Org-mode
(global-set-key (kbd "C-c l") 'org-store-link)
(global-set-key (kbd "C-c a") 'org-agenda)
(global-set-key (kbd "C-c -") 'helm-org-agenda-files-headings)
(add-hook 'org-mode-hook (lambda () (local-set-key (kbd "C-c -") 'helm-org-agenda-files-headings)))


(setq org-link-abbrev-alist
      '(
	("google"    . "http://www.google.com/search?q=")
	("ccm" . "https://ccm-q1labs.canlab.ibm.com:9449/ccm/web/projects/Security%20Intelligence#action=com.ibm.team.workitem.viewWorkItem&id=")
	))

(let
    ((file-of-agenda-files "/tmp/org.list"))
  (if (file-exists-p file-of-agenda-files)
      (setq org-agenda-files file-of-agenda-files)
    (message "file %s does not exist; make an org.sh script to generate it" file-of-agenda-files)))

;; Next in  helm-ag; sounds cool.

;; Magit
(if (fboundp 'magit-status)
    (global-set-key (kbd "C-x g") 'magit-status)
  (message "Magit is not installed"))

;; Work process
(defun kdl-new-wi (x y) "Create a new WI"
	    (interactive "sWI:\nsDescription:")
	    (inkdl-create-wi x y))

(defun inkdl-create-wi (wi description)
  (let*
      ((wi-place (concat "/home/konsl/wi/" wi))
       (investigation (concat wi-place "/xfile-" wi ".org"))
       (title (format "* [[ccm:%s]] : %s" wi description)))
    (progn
      (message (format "Creating %s titled %s in %s" investigation title wi-place))
      (if (not (file-exists-p wi-place))
	  (mkdir wi-place))
      (find-file investigation)
      (insert title))))

;; Anki
(defun kdlin-replace (a b) "Replace a to b in buff"
       (interactive "sA:\nsB:")
       (save-excursion
	 (goto-char (point-min))
	 (replace-regexp a b)))

(defun kdl-make-anki-entry (f b) "Make entry for Anki"
       (interactive "sFront:\nsBack:")
       (let* ((store "/home/konsl/projects/anki/to_import.txt")
	      (front f)
	      (back b)
	      (tmp-buffer "anki-buffer")
	      (now (current-buffer)))
	 (switch-to-buffer "anki-space")
	 (delete-region (point-max) (point-min))
	 (insert (format "%s\t%s" front back))
	 (kdlin-replace "<" "&lt;")
	 (kdlin-replace ">" "&gt;")
	 (kdlin-replace "\n" "<br/>")
	 (kill-ring-save (point-min) (point-max))
	 (find-file store)
	 (goto-char (point-max))
	 (insert "\n")
	 (yank)
	 (save-buffer)
	 (switch-to-buffer now)))

(global-set-key (kbd "C-c q") 'kdl-make-anki-entry)

(switch-to-buffer "*scratch*")
