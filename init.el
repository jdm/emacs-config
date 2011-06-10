(if (not (eq (string-match "23" (emacs-version)) nil))
    (push '(font . "Liberation Mono-8") default-frame-alist)
  (push '(font . "7x13") default-frame-alist))

(add-to-list 'load-path (expand-file-name "~/.emacs.d/"))
(setq load-path (append (list (expand-file-name "~/.emacs.d")) load-path))

(defconst dave-c-style
  `(
    ;; One indent level is 2 spaces.
    (c-basic-offset . 2)
    ;; Use only spaces, never tabs.
    (indent-tabs-mode . nil)
    ;; Comments are aligned as you'd naturally expect.
    (c-comment-only-line-offset . 0)
    ;; By default, cc-mode auto-newlines both before and after
    ;; braces. We want a mix depending on the context of the brace.
    (c-hanging-braces-alist . ((defun-open after)
                               (defun-close before after)
                               (class-open after)
                               (class-close before after)
                               (namespace-open after)
                               (inline-open after)
                               (inline-close before after)
                               (block-open after)
                               (block-close . c-snug-do-while)
                               (extern-lang-open after)
                               (extern-lang-close after)
                               (statement-case-open after)
                               (substatement-open after)))
    ;; Same thing as above, but with colons. We want a mix of before,
    ;; after, or none depending on the context of the colon.
    (c-hanging-colons-alist . (
                               (case-label)
                               (label after)
                               (access-label after)
                               (member-init-intro before)
                               (inher-intro)
                               ))
    ;; Same, but for semicolons and commas. These settings make for a
    ;; decently sane behavior there.
    (c-hanging-semi&comma-criteria
     . (c-semi&comma-no-newlines-for-oneline-inliners
        c-semi&comma-inside-parenlist
        c-semi&comma-no-newlines-before-nonblanks))
    ;; Indent comment-only lines the same as the surrounding code.
    (c-indent-comments-syntactically-p . t)
    ;; Inline comments started/aligned with M-; should start at column
    ;; 40 (or later, if necessary)
    (comment-column . 40)
    ;; Comments placed after code have 2 spaces between the code and
    ;; the comment.
    (c-indent-comment-alist . ((other . (space . 2))))
    ;; Whitespace cleanup functions we use.
    (c-cleanup-list . (brace-else-brace ; } else {
                       brace-elseif-brace ; } else if (...) {
                       brace-catch-brace  ; } catch ... {
                       empty-defun-braces ; class Spam {}
                       defun-close-semi   ; };
                       list-close-comma   ; },
                       scope-operator))   ; split ::
    ;; How indentation should change in various contexts.  I can't
    ;; seem to find a reference for the syntactic elements referenced
    ;; below, but I like the resulting style, so I'll just go with it.
    (c-offsets-alist . (
                        (arglist-intro . ++)
                        (func-decl-cont . ++)
                        (member-init-intro . 0)
                        (inher-intro . ++)
                        (comment-intro . 0)
                        (arglist-close . c-lineup-arglist)
                        (topmost-intro . 0)
                        (block-open . 0)
                        (inline-open . 0)
                        (substatement-open . 0)
                        (statement-cont . ++)
                        (label . /)
                        (case-label . +)
                        (statement-case-open . +)
                        (statement-case-intro . +)
                        (access-label . /)
                        (innamespace . 0)
                        ))
    )
  "Dave's C/C++ Programming Style")

(defun dave-set-c-style ()
  (interactive)
  (make-local-variable 'c-tab-always-indent)
  (setq c-tab-always-indent t)
  (define-key c-mode-base-map (kbd "C-c o") 'ff-find-other-file)
  (c-add-style "Dave" dave-c-style t))

(add-hook 'c-mode-common-hook 'dave-set-c-style)

(defun switch-hg-reject ()
  (interactive)
  (let ((other-file
	 (if (string= (substring (buffer-file-name) -4 nil) ".rej")
	     (substring (buffer-file-name) 0 -4)
	   (concat (buffer-file-name) ".rej"))))
    (if (file-exists-p other-file)
	(save-selected-window
	  (switch-to-buffer-other-window (find-file-noselect other-file)))
      (message "No alternate reject file found"))))

(defun kill-hg-reject ()
  (interactive)
  (let ((reject-file (concat (buffer-file-name) ".rej")))
    (kill-buffer
     (find-buffer-visiting reject-file))))

(global-set-key (kbd "C-c r") 'switch-hg-reject)
(global-set-key (kbd "C-x r") 'kill-hg-reject)

;; This adds additional extensions which indicate files normally
;; handled by cc-mode.
(setq auto-mode-alist
      (append '(("\\.C$"  . c++-mode)
		("\\.cc$" . c++-mode)
		("\\.hh$" . c++-mode)
		("\\.h$"  . c++-mode)
                ("\\.rs$" . ruse-mode))
	      auto-mode-alist))

;; Set stroustrup as the default style for C/C++ code
(setq c-default-style "stroustrup")

;; Set up C++ mode hook
(defun my-c++-mode-hook ()
  ;; Tell cc-mode not to check for old-style (K&R) function declarations.
  ;; This speeds up indenting a lot.
  ;(setq c-recognize-knr-p nil)

  ;; switch/case:  make each case line indent from switch
;;  (c-set-offset 'case-label '+)
;;  (c-set-offset 'access-label '+)
;;  (c-set-offset 'topmost-intro '+)

  ;; Automatically indent after a newline (like vi)
  (local-set-key '[(return)] 'newline-and-indent)

  (c-toggle-hungry-state 1)

  ;; Tab sanity: match the C indent, but don't insert new tabs (use spaces)
  (setq tab-width 4)
  (setq indent-tabs-mode nil))

(add-hook 'c++-mode-hook 'my-c++-mode-hook)

(defun my-js2-mode-hook ()
  (setq-default indent-tabs-mode nil))

(add-hook 'js2-mode-hook 'my-js2-mode-hook)

(defun my-ruby-mode-hook ()
  (define-key ruby-mode-map "\C-m" 'newline-and-indent))

(add-hook 'ruby-mode-hook 'my-ruby-mode-hook)

(defadvice yank (after indent-region activate)
  (let ((mark-even-if-inactive t))
    (if (member major-mode '(emacs-lisp-mode scheme-mode lisp-mode
					c-mode c++-mode objc-mode
					LaTeX-mode TeX-mode ruby-mode))
	(indent-region (region-beginning) (region-end) nil))))
           
(show-paren-mode 1)
(transient-mark-mode 1)
(display-battery-mode 1)
(display-time-mode 1)
(scroll-bar-mode nil)
(menu-bar-mode nil)
(tool-bar-mode nil)

;(load-file "~/.xemacs/color-theme.el")
(require 'color-theme)
(color-theme-initialize)

(defun color-theme-djcb-dark ()
  "dark color theme created by djcb, Jan. 2009."
  (interactive)
  (color-theme-install
    '(color-theme-djcb-dark
       ((foreground-color . "#a9eadf")
         (background-color . "black") 
         (background-mode . dark))
       (bold ((t (:bold t))))
       (bold-italic ((t (:italic t :bold t))))
       (default ((t (nil))))
       
       (font-lock-builtin-face ((t (:italic t :foreground "#a96da0"))))
       (font-lock-comment-face ((t (:italic t :foreground "#bbbbbb"))))
       (font-lock-comment-delimiter-face ((t (:foreground "#666666"))))
       (font-lock-constant-face ((t (:bold t :foreground "#197b6e"))))
       (font-lock-doc-string-face ((t (:foreground "#3041c4"))))
       (font-lock-doc-face ((t (:foreground "gray"))))
       (font-lock-reference-face ((t (:foreground "white"))))
       (font-lock-function-name-face ((t (:foreground "#356da0"))))
       (font-lock-keyword-face ((t (:bold t :foreground "#bcf0f1"))))
       (font-lock-preprocessor-face ((t (:foreground "#e3ea94"))))
       (font-lock-string-face ((t (:foreground "#ffffff"))))
       (font-lock-type-face ((t (:bold t :foreground "#364498"))))
       (font-lock-variable-name-face ((t (:foreground "#7685de"))))
       (font-lock-warning-face ((t (:bold t :italic nil :underline nil 
                                     :foreground "yellow"))))
       (hl-line ((t (:background "#112233"))))
       (mode-line ((t (:foreground "#ffffff" :background "#333333"))))
       (region ((t (:foreground nil :background "#555555"))))
       (show-paren-match-face ((t (:bold t :foreground "#ffffff" 
                                    :background "#050505")))))))

;; make zenburn available to color-theme-select
(add-to-list 'color-themes
             '(color-theme-zenburn "ZenBurn" 
                                   "Daniel Brockman <daniel@brockman.se>"))
;; load the color-theme elisp itself
(load-file "~/.emacs.d/themes/zenburn.el")

;; activate it
(color-theme-zenburn)

;(defun pretty-greek ()
; (let ((greek '("alpha" "beta" "gamma" "delta" "epsilon" "zeta" "eta" "theta" "iota" "kappa" "lambda" "mu" "nu" "xi" "omicron" "pi" "rho" "sigma_final" "sigma" "tau" "upsilon" "phi" "chi" "psi" "omega")))
;   (loop for word in greek
 ;        for code = 97 then (+ 1 code)
;         do  (let ((greek-char (make-char 'greek-iso8859-7 code))) 
;               (font-lock-add-keywords nil
;                                       `((,(concatenate 'string "\\(^\\|[^a-zA-Z0-9]\\)\\(" word "\\)[a-zA-Z]")
;                                          (0 (progn (decompose-region (match-beginning 2) (match-end 2))
;                                                    nil)))))
;               (font-lock-add-keywords nil 
;                                       `((,(concatenate 'string "\\(^\\|[^a-zA-Z0-9]\\)\\(" word "\\)[^a-zA-Z]")
;                                          (0 (progn (compose-region (match-beginning 2) (match-end 2)
;                                                                    ,greek-char)
;                                                    nil)))))))))

;(add-hook 'lisp-mode-hook 'pretty-greek)
;(add-hook 'emacs-lisp-mode-hook 'pretty-greek)
;(add-hook 'text-mode-hook 'pretty-greek)

;(load "~/.emacs.d/pretty-mode.el")
(require 'pretty-mode)
(global-pretty-mode 1)
;(add-hook 'text-mode-hook 'turn-on-pretty-mode)

;(require 'lilypond-mode)
;(autoload 'LilyPond-mode "lilypond-mode" "LilyPond Editing Mode" t)
;(add-to-list 'auto-mode-alist '("\\.ly$" . LilyPond-mode))
;(add-to-list 'auto-mode-alist '("\\.ily$" . LilyPond-mode))
;(add-hook 'LilyPond-mode-hook (lambda () (turn-on-font-lock)))

(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

(require 'ido)                      ; ido is part of emacs 
(ido-mode t)                        ; for both buffers and files
(setq 
 ido-ignore-buffers               ; ignore these guys
 '("\\` " "^\*Mess" "^\*Back" ".*Completion" "^\*Ido" "^\*scratch")
 ido-work-directory-list '("~/" "~/Desktop" "~/Documents")
 ido-create-new-buffer 'always
 ido-case-fold  t                 ; be case-insensitive
 ido-use-filename-at-point nil    ; don't use filename at point (annoying)
 ido-use-url-at-point nil         ;  don't use url at point (annoying)
 ido-enable-flex-matching t       ; be flexible
 ido-max-prospects 6              ; don't spam my minibuffer
 ido-confirm-unique-completion t) ; wait for RET, even with unique completion

(global-set-key (kbd "<f12>") ; make F12 switch to .emacs; create if needed
  (lambda()(interactive)(find-file "~/.emacs.d/init.el"))) 

(require 'smex)
(smex-initialize)
(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands)
;(global-set-key (kbd "C-c M-x") 'smex-update-and-run)
;; This is your old M-x.
(global-set-key (kbd "C-c M-x") 'execute-extended-command)

;;; This was installed by package-install.el.
;;; This provides support for the package system and
;;; interfacing with ELPA, the package archive.
;;; Move this code earlier if you want to reference
;;; packages in your .emacs.
(when
    (load
     (expand-file-name "~/.emacs.d/elpa/package.el"))
  (package-initialize))
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(browse-url-browser-function (quote browse-url-firefox))
 '(browse-url-firefox-new-window-is-tab t)
 '(browse-url-firefox-program "firefox")
 '(browse-url-generic-program "chromium-browser")
 '(erc-join-buffer (quote bury))
 '(erc-modules (quote (autojoin button completion fill irccontrols match menu netsplit noncommands readonly ring scrolltobottom services stamp track)))
 '(ido-everywhere t)
 '(js2-basic-offset 2)
 '(js2-bounce-indent-p t)
 '(js2-enter-indents-newline t)
 '(js2-indent-on-enter-key nil)
 '(js2-skip-preprocessor-directives t))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )

(setq tls-program '("openssl s_client -connect %h:%p -no_ssl2 -ign_eof
                                      -CAfile /home/t_mattjo/.private/CAs.pem 
                                      -cert /home/t_mattjo/.private/jdm.pem" 
		    "gnutls-cli --priority secure256 
                                 --x509cafile /home/t_mattjo/.private/CAs.pem 
                                 --x509certfile /home/t_mattjo/.private/jdm.pem -p %p %h" 
		    "gnutls-cli --priority secure256 -p %p %h"))

(require 'erc-log)
(require 'erc-join)
(require 'erc-match)
(setq erc-keywords '("Revvy" "NichardRixon" "jdm" "j4matthe" "jdm-" "jdm`"))
(setq erc-current-nick-highlight-type 'nick)
(setq erc-track-exclude-types '("JOIN" "PART" "QUIT" "NICK" "MODE"))
(setq erc-track-use-faces t)
(setq erc-track-faces-priority-list
      '(erc-current-nick-face erc-keyword-face erc-default-face erc-action-face))
(setq erc-track-priority-faces-only 'all)

;(setq erc-server "irc.esper.net"
;      erc-port 6667
;      erc-nick "Revvy"
;      erc-prompt-for-password nil)
(setq erc-server "irc.mozilla.org"
      erc-port 6667
      erc-nick "jdm"
      erc-prompt-for-password nil)
(erc-autojoin-mode 1)
(setq erc-autojoin-channels-alist
      '(;("freenode.net" "#jruby" "#mixxx")
	("esper.net" "#batcafe" "#neocesspool")
	("mozilla.org" "#content" "#mobile" "#static" "#foxymonkies" "#interns" "#jsapi" "#gfx" "#developers" "#rust" "#mozillians" "#coding" "#lounge" "#seneca" "#introduction")))
(setq erc-auto-query 'window-noselect)

(defface erc-header-line-disconnected
  '((t (:foreground "black" :background "indianred")))
  "Face to use when ERC has been disconnected.")

(defun erc-update-header-line-show-disconnected ()
  "Use a different face in the header-line when disconnected."
  (erc-with-server-buffer
    (cond ((erc-server-process-alive) 'erc-header-line)
          (t 'erc-header-line-disconnected))))
(setq erc-header-line-face-method 'erc-update-header-line-show-disconnected)

(setq erc-log-channels-directory "~/.emacs.d/logs/")
(setq erc-save-buffer-on-part nil)
(setq erc-save-queries-on-quit nil
      erc-log-write-after-send t
      erc-log-write-after-insert t)
(add-hook 'erc-insert-post-hook 'erc-save-buffer-in-logs)
(erc-log-enable)

;(defadvice save-buffers-kill-emacs (before save-logs (arg) activate)
;  (save-some-buffers t (lambda () (when (and (eq major-mode 'erc-mode)
;					(not (null buffer-file-name)))))))

(defun erc-do-notify (msg)
  (shell-command (concat "notify-send -t 0 \"" msg "\"")))

(defun erc-notify-on-msg (msg)
  (if (string-match "jdm:" msg)
      (erc-do-notify msg)))

(defun erc-notify-on-privmsg (proc parsed)
  (let ((nick (car (erc-parse-user (erc-response.sender parsed))))
	(target (car (erc-response.command-args parsed)))
	(msg (erc-response.contents parsed)))
    (when (and (erc-current-nick-p target)
	       (not (erc-is-message-ctcp-and-not-action-p msg)))
      (erc-do-notify msg)
      nil)))

(add-hook 'erc-insert-pre-hook 'erc-notify-on-msg)
(add-hook 'erc-server-PRIVMSG-functions 'erc-notify-on-privmsg)

(defun gse-prompt-to-compile-init-file ()
  (interactive)
  (if (and
       (string-equal buffer-file-name "/home/t_mattjo/.emacs.d/init.el")
       (file-newer-than-file-p "~/.emacs.d/init.el" "~/.emacs.d/init.elc")
       (y-or-n-p "byte-compile init.el? "))
      (byte-compile-file "~/.emacs.d/init.el")))

(add-hook 'kill-buffer-hook 'gse-prompt-to-compile-init-file)

(setq inhibit-startup-message t)

(windmove-default-keybindings 'meta)

(setq debug-on-error t)

(setq kill-whole-line t)

(fset 'yes-or-no-p 'y-or-n-p)

(highlight-parentheses-mode t)
(require 'highline)
(highline-mode-on)
(set-face-background 'highline-face "#555")

(require 'smooth-scrolling)
(setq smooth-scroll-margin 5)

;(load (expand-file-name "~/.emacs.d/haskell-mode/haskell-site-file"))
;(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
;(add-hook 'haskell-mode-hook 'turn-on-haskell-indent)

(require 'ack)

(require 'project-root)
(setq project-roots
      '(("fheroes2"
	 ;:path-matches ".*/fheroes2/mods/.*"
	 :root-contains-files ("fheroes2-docs.conf")
	 :compile ("make -j4 DEBUG=1")
	 :on-hit (lambda (p) (message (car p))))
	("megazeux"
	 :root-contains-files ("valgrind.supp" "platform.inc")
	 :compile ("make -k -j2")
	 :on-hit (lambda (p) (message (car p))))
	("firefox"
	 :root-contains-files ("client.mk")
	 :compile ("make -f client.mk build")
	 :on-hit (lambda (p) (message (car p))))
	("jetpack"
	 :root-contains-files ("install.rdf")
	 :compile ("")
	 :on-hit (lambda (p) (message (car p))))
	("jruby"
	 :root-contains-files ("build.xml")
	 :compile ("ant")
	 :on-hit (lambda (p) (message (car p))))
	))

(global-set-key (kbd "C-c p f") 'project-root-find-file)
(global-set-key (kbd "C-c p g") 'project-root-grep)
(global-set-key (kbd "C-c p a") 'project-root-ack)
(global-set-key (kbd "C-c p d") 'project-root-goto-root)
(global-set-key (kbd "C-c p p") 'project-root-run-default-command)

(global-set-key (kbd "C-c p M-x")
                 'project-root-execute-extended-command)

(defun project-compile ()
  (interactive)
  (recenter (/ (window-height) 2))
  (with-project-root 
      (progn
	(set (make-local-variable 'compile-command)
	     (car (project-root-data :compile project-details)))
	(compile compile-command))))

(setq compilation-scroll-output t)
(global-set-key [(f5)] 'project-compile)
(setq compilation-window-height 24)

(setq compilation-finish-functions
      '((lambda (buf str)
	  (if (string-equal "*compilation*" (buffer-name buf))

	      (if (string-match "exited abnormally" str)

		  ;;there were errors
		  (message "compilation errors, press C-x ` to visit")

		;;no errors, make the compilation window go away in 0.5 seconds
		(run-at-time 0.5 nil 'delete-windows-on buf)
		(message "NO COMPILATION ERRORS!"))))))

(setq split-height-threshold 500)

(setq special-display-buffer-names
      '("*compilation*" "*ack*"))

(setq special-display-function
      (lambda (buffer &optional args)
	(save-excursion
	  (save-selected-window
	    (split-window)
	    (switch-to-buffer buffer)
	    (enlarge-window (- compilation-window-height (window-height)))
	    (selected-window)))))

(setq x-select-enable-clipboard t)
(setq temporary-file-directory "~/.emacs.d/tmp/")
(setq confirm-nonexistent-file-or-buffer nil)

(require 'uniquify)
(setq uniquify-buffer-name-style 'reverse)
(setq uniquify-separator "|")
(setq uniquify-after-kill-buffer-p t)
(setq uniquify-ignore-buffers-re "^\\*")

(push '("." . "~/.emacs-backups") backup-directory-alist)

(put 'narrow-to-region 'disabled nil)

(defun sudo-edit (&optional arg)
  (interactive "p")
  (if arg
      (find-file (concat "/sudo:root@localhost:" (ido-read-file-name "File: ")))
    (find-alternate-file (concat "/sudo:root@localhost:" buffer-file-name))))

(defun sudo-edit-current-file ()
  (interactive)
  (find-alternate-file (concat "/sudo:root@localhost:" (buffer-file-name (current-buffer)))))
(global-set-key (kbd "C-c C-r") 'sudo-edit-current-file)

(setq 
 bookmark-default-file "~/.emacs.d/bookmarks" ;; keep my ~/ clean
 bookmark-save-flag 1)                        ;; autosave each change

;(load "starttls")
(require 'tls)
;(setq starttls-use-gnutls t)
;(setq send-mail-function 'smtpmail-send-it
;      message-send-mail-function 'smtpmail-send-it
;      smtpmail-starttls-credentials
;      '(("smtp.gmail.com" 587 nil nil))
;      smtpmail-auth-credentials
;      (expand-file-name "~/.authinfo")
;      smtpmail-default-smtp-server "smtp.gmail.com"
;      smtpmail-smtp-server "smtp.gmail.com"
;      smtpmail-smtp-service 587
;      smtpmail-debug-info t
;      starttls-use-gnutls t)
;(require 'smtpmail)

(defadvice kill-ring-save (before slick-copy activate compile) "When called
  interactively with no active region, copy a single line instead."
  (interactive (if mark-active (list (region-beginning) (region-end)) (message
								       "Copied line") (list (line-beginning-position) (line-beginning-position
														       2)))))

(defadvice kill-region (before slick-cut activate compile)
  "When called interactively with no active region, kill a single line instead."
  (interactive
   (if mark-active (list (region-beginning) (region-end))
     (list (line-beginning-position)
	   (line-beginning-position 2)))))

(autoload 'cycle-buffer "cycle-buffer" "Cycle forward." t)
(autoload 'cycle-buffer-backward "cycle-buffer" "Cycle backward." t)
(autoload 'cycle-buffer-permissive "cycle-buffer" "Cycle forward allowing *buffers*." t)
(autoload 'cycle-buffer-backward-permissive "cycle-buffer" "Cycle backward allowing *buffers*." t)
(autoload 'cycle-buffer-toggle-interesting "cycle-buffer" "Toggle if this buffer will be considered." t)
(global-set-key [(f1)]        'cycle-buffer-backward)
(global-set-key [(f2)]        'cycle-buffer)
(global-set-key [(shift f1)]  'cycle-buffer-backward-permissive)
(global-set-key [(shift f2)]  'cycle-buffer-permissive)

(load-file "~/.emacs.d/word-count.el")

(defun goto-match-paren (arg)
  "Go to the matching parenthesis if on parenthesis. Else go to the
   opening parenthesis one level up."
  (interactive "p")
  (cond ((looking-at "\\s\(") (forward-list 1))
	(t
	 (backward-char 1)
	 (cond ((looking-at "\\s\)")
		(forward-char 1) (backward-list 1))
	       (t
		(while (not (looking-at "\\s("))
		  (backward-char 1)
		  (cond ((looking-at "\\s\)")
			 (message "->> )")
			 (forward-char 1)
			 (backward-list 1)
			 (backward-char 1)))
		  ))))))

(global-set-key (kbd "M-p") 'goto-match-paren)

(defun insert-mpl-tri-license () (interactive)
  (insert
   "/* -*- Mode: C++; tab-width: 8; indent-tabs-mode: nil; c-basic-offset: 2 -*-\n"
   " * vim: sw=2 ts=8 et :\n"
   " */\n"
   "/* ***** BEGIN LICENSE BLOCK *****\n"
   " * Version: MPL 1.1/GPL 2.0/LGPL 2.1\n"
   " *\n"
   " * The contents of this file are subject to the Mozilla Public License Version\n"
   " * 1.1 (the \"License\"); you may not use this file except in compliance with\n"
   " * the License. You may obtain a copy of the License at:\n"
   " * http://www.mozilla.org/MPL/\n"
   " *\n"
   " * Software distributed under the License is distributed on an \"AS IS\" basis,\n"
   " * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License\n"
   " * for the specific language governing rights and limitations under the\n"
   " * License.\n"
   " *\n"
   " * The Original Code is Mozilla Code.\n"
   " *\n"
   " * The Initial Developer of the Original Code is\n"
   " *   The Mozilla Foundation\n"
   " * Portions created by the Initial Developer are Copyright (C) 2010\n"
   " * the Initial Developer. All Rights Reserved.\n"
   " *\n"
   " * Contributor(s):\n"
   " *   Josh Matthews <josh@joshmatthews.net>\n"
   " *\n"
   " * Alternatively, the contents of this file may be used under the terms of\n"
   " * either the GNU General Public License Version 2 or later (the \"GPL\"), or\n"
   " * the GNU Lesser General Public License Version 2.1 or later (the \"LGPL\"),\n"
   " * in which case the provisions of the GPL or the LGPL are applicable instead\n"
   " * of those above. If you wish to allow use of your version of this file only\n"
   " * under the terms of either the GPL or the LGPL, and not to allow others to\n"
   " * use your version of this file under the terms of the MPL, indicate your\n"
   " * decision by deleting the provisions above and replace them with the notice\n"
   " * and other provisions required by the GPL or the LGPL. If you do not delete\n"
   " * the provisions above, a recipient may use your version of this file under\n"
   " * the terms of any one of the MPL, the GPL or the LGPL.\n"
   " *\n"
   " * ***** END LICENSE BLOCK ***** */\n"))
(global-set-key "\C-xg" 'insert-mpl-tri-license)