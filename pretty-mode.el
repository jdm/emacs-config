;;; -*- coding: utf-8 -*-
;; Minor mode for redisplaying parts of the buffer as pretty symbols
;; originally modified from Trent Buck's version at http://paste.lisp.org/display/42335,2/raw
;; Also includes code from `sml-mode'
;; See also http://www.emacswiki.org/cgi-bin/wiki/PrettyLambda
;; written by Arthur Danskin <arthurdanskin@gmail.com>
;;
;; to install:
;; (require 'pretty-mode)
;; (global-pretty-mode 1)
;; or
;; (add-hook 'my-pretty-language-hook 'turn-on-pretty-mode)


(require 'cl)

;; modified from `sml-mode'
(defun pretty-font-lock-compose-symbol (alist)
  "Compose a sequence of ascii chars into a symbol."
  (let* ((start (match-beginning 0))
	 (end (match-end 0))
         (syntax (char-syntax (char-after start))))
    (if (or (if (eq syntax ?w)
                (or (eq (char-syntax (char-before start)) ?w)
                    (eq (char-syntax (char-after end)) ?w))
              (memq (char-syntax (char-before start)) '(?. ?\\)))
            (memq (get-text-property start 'face)
                  '(font-lock-doc-face font-lock-string-face
                                       font-lock-comment-face)))
        (remove-text-properties start end '(composition))
      (compose-region start end (cdr (assoc (match-string 0) alist)))
;;;       (add-text-properties start end `(display ,repl)))
      ))
  ;; Return nil because we're not adding any face property.
  nil)

(defvar pretty-interaction-mode-alist
  '((inferior-scheme-mode . scheme-mode)
    (lisp-interaction-mode . emacs-lisp-mode)
    (inferior-lisp-mode . lisp-mode)
    (inferior-ess-mode . ess-mode)
    (inf-haskell-mode . haskell-mode)
    (tuareg-interactive-mode . tuareg-mode)
    (inferior-python-mode . python-mode)
    (inferior-octave-mode . octave-mode)
    (inferior-ruby-mode . ruby-mode))
  "Alist mapping from inferior process interaction modes to their
  corresponding script editing modes.")


(defun pretty-font-lock-keywords (alist)
  "Return a `font-lock-keywords' style entry for replacing
regular expressions with symbols. ALIST has the form ((STRING .
REPLACE-CHAR) ...)."
  (when alist
    `((,(regexp-opt (mapcar 'car alist))
       (0 (pretty-font-lock-compose-symbol
           ',alist))))))

(defun pretty-keywords (&optional mode)
  "Return the font-lock keywords for MODE, or the current mode if
MODE is nil. Return nil if there are no keywords."
  (let* ((mode (or mode major-mode))
         (kwds (cdr-safe
                (or (assoc mode pretty-patterns)
                    (assoc (cdr-safe
                            (assoc mode pretty-interaction-mode-alist))
                           pretty-patterns)))))
    (pretty-font-lock-keywords kwds)))

(defgroup pretty nil "Minor mode for replacing text with symbols "
  :group 'faces)

(define-minor-mode pretty-mode
  "Toggle Pretty minor mode.
With arg, turn Pretty minor mode on if arg is positive, off otherwise.

Pretty mode builds on `font-lock-mode'. Instead of highlighting
keywords, it replaces them with symbols. For example, lambda is
displayed as λ in lisp modes."
  :group 'pretty
;  :lighter " λ"
  (if pretty-mode
      (progn
        (font-lock-add-keywords nil (pretty-keywords) t)
        (font-lock-fontify-buffer))
    (font-lock-remove-keywords nil (pretty-keywords))
    (remove-text-properties (point-min) (point-max) '(composition nil))))

(defun turn-on-pretty-if-desired ()
  "Turn on `pretty-mode' if the current major mode supports it."
  (if (pretty-keywords)
      (pretty-mode 1)))

(define-globalized-minor-mode global-pretty-mode
  pretty-mode turn-on-pretty-if-desired
  :init-value t)

(defun turn-off-pretty-mode ()
  (interactive)
  (pretty-mode -1))


(defun turn-on-pretty-mode ()
  (interactive)
  (pretty-mode +1))

(defun pretty-compile-patterns (patterns)
  "Set pretty patterns in a convenient way.

PATTERNS should be of the form ((GLYPH (REGEXP MODE ...) ...)
...). GLYPH should be a character. MODE should be the name of a
major mode without the \"-mode\". Returns patterns in the form
expected by `pretty-patterns'"
  (let ((pretty-patterns))
    (loop for (glyph . pairs) in patterns do
          (loop for (regexp . major-modes) in pairs do
                (loop for mode in major-modes do
                      (let* ((mode (intern (concat (symbol-name mode)
                                                   "-mode")))
                             (assoc-pair (assoc mode pretty-patterns))
                            
                             (entry (cons regexp glyph)))
                        (if assoc-pair
                            (push entry (cdr assoc-pair))
                          (push (cons mode (list entry))
                                pretty-patterns))))))
    pretty-patterns))

;;; (setq-default pretty-patterns pretty-patterns-default)
(defconst pretty-patterns-default
  (let* ((lispy '(scheme emacs-lisp lisp))
         (mley '(tuareg haskell sml))
         (c-like '(c c++ perl sh python java ess ruby))
         (all (append lispy mley c-like (list 'octave) (list 'text))))
    (pretty-compile-patterns
     `(
       (?≠ ("!=" ,@c-like scheme octave text)
           ("<>" tuareg octave)
           ("~=" octave)
           ("/=" haskell))
       (?≤ ("<=" ,@all))
       (?≥ (">=" ,@all))
       (?← ("<-" ,@mley ess text))
       (?→ ("->" ,@mley ess c c++ perl text))
       (?↑ ("\\^" tuareg))
       (?⇒ ("=>" sml perl ruby text))
       (?∅ ("nil" emacs-lisp ruby)
           ("null" scheme java text)
           ("NULL" c c++)
;;;         ("None" python)
           ("()" ,@mley))
;;;     (?… ("\\.\\.\\." scheme))
      (?∀ ("List.for_all" tuareg)
	  ("forall" text))
      (?∃ ("List.exists" tuareg)
	  ("exists" text))
        (?∈ ("List.mem" tuareg)
            ("member" ,@lispy)
	    ("element" text))
        (?∉ ("notelement" text))
       (?√ ("sqrt" ,@all))
       (?∑ ("sum" python)
	   ("sigma" text))
       (?α ("alpha" ,@all)
           ("'a" ,@mley))
       (?β ("beta" ,@all)
           ("'b" ,@mley))
       (?γ ("gamma" ,@all)
           ("'c" ,@mley))
       (?δ ("delta" ,@all)
           ("'d" ,@mley))
       (?ε ("epsilon" ,@all))
       (?θ ("theta" ,@all))
       (?λ ("lambda" ,@all)
;;;            ("case-\\(lambda\\)" scheme)
           ("fn" sml)
           ("fun" tuareg)
           ("\\\\" haskell))
       (?π ("pi" ,@all)
           ("M_PI" c c++))
       (?φ ("psi" ,@all))

       (?² ("**2" python tuareg octave))
       (?³ ("**3" python tuareg octave))
       (?ⁿ ("**n" python tuareg octave))
       (?₀ ("[0]" ,@c-like)
           ("(0)" octave)
           (".(0)" tuareg)
	   ("_0"  text))
       (?₁ ("[1]" ,@c-like)
           ("(1)" octave)
           (".(1)" tuareg)
	   ("_1"  text))
       (?₂ ("[2]" ,@c-like)
           ("(2)" octave)
           (".(2)" tuareg)
	   ("_2"  text))
       (?₃ ("[3]" ,@c-like)
           ("(3)" octave)
           (".(3)" tuareg)
	   ("_3"  text))
       (?₄ ("[4]" ,@c-like)
           ("(4)" octave)
           (".(4)" tuareg)
	   ("_4"  text))
;;;        (?ₐ ("[a]" ,@c-like)
;;;            ("(a)" octave))
;;;        (?ₓ ("[x]" ,@c-like)
;;;            ("(x)" octave))
;;;      (?₅ ("[5]") ,@c-like)
;;;      (?₆ ("[6]") ,@c-like)
;;;      (?₇ ("[7]") ,@c-like)
;;;      (?₈ ("[8]") ,@c-like)
;;;      (?₉ ("[9]") ,@c-like)

        (?⋂ ("<intersect>" text)
	    ("<intersection>" text))  ;(,@lispen text))
        (?⋃ ("<union>"     text))  ;(,@lispen text))

   
	(?∧ ("\\<And\\>"     emacs-lisp lisp python)
	    ("/\\" text)
;;;        ("\\<andalso\\>" sml)
        ("&&"            c c++ perl haskell))
    (?∨ ("\\<or\\>"      emacs-lisp lisp)
	("\\/" text)
;;;        ("\\<orelse\\>"  sml)
        ("||"            c c++ perl haskell))
    (?¬ ("\\<!\\>"       c c++ perl sh)
        ("\\<not\\>"     lisp emacs-lisp scheme haskell sml)
	("~" text))

       )))
  "default value for `pretty-patterns'")

;; TODO fix type
(defcustom pretty-patterns pretty-patterns-default
  "*List of pretty patterns.

Should be a list of the form ((MODE ((REGEXP . GLYPH) ...)) ...)"
  :group 'pretty
  :type '(alist :key-type variable :value-type (alist :key-type (string) :value-type (character))))


(defun pretty-add-keywords (mode keywords)
  "Add pretty character KEYWORDS to MODE

MODE should be a symbol, the major mode command name, such as
`c-mode' or nil. If nil, pretty keywords are added to the current
buffer. KEYWORDS should be a list where each element has the
form (REGEXP . CHAR). REGEXP will be replaced with CHAR in the
relevant buffer(s)."
  (font-lock-add-keywords
   mode (mapcar (lambda (kw) `((,(car kw)
                           (0 (prog1 nil
                                (compose-region (match-beginning 0)
                                                (match-end 0)
                                                ,(cdr kw)))))))
                keywords)))

(defun pretty-regexp (regexp glyph)
  "Replace REGEXP with GLYPH in buffer."
  (interactive "MRegexp to replace: 
MCharacter to replace with: ")
  (pretty-add-keywords nil `((,regexp . ,(string-to-char glyph))))
  (font-lock-fontify-buffer))




(provide 'pretty-mode)

