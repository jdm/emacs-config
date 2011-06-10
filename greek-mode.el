;;; $Header: greek-mode.el version 1.0.1 $
;;; Author: Sarantos Kapidakis, sarantos@csd.uch.gr
;;; See http://www.ics.forth.gr/~sarantos/src/EMACS+GREEK for instructions

;;; This file is not part of the GNU Emacs distribution (yet).

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY.  No author or distributor
;; accepts responsibility to anyone for the consequences of using it
;; or for whether it serves any particular purpose or works at all,
;; unless he says so in writing.  Refer to the GNU Emacs General Public
;; License for full details.

;; Everyone is granted permission to copy, modify and redistribute
;; this file, but only under the conditions described in the
;; GNU Emacs General Public License.   A copy of this license is
;; supposed to have been given to you along with GNU Emacs so you
;; can know your rights and responsibilities.  It should be in a
;; file named COPYING.  Among other things, the copyright notice
;; and this notice must be preserved on all copies.

;;; Provide the functions to deal with font-correspondance, input
;;; and manipulation of the greek characters.
;;load: (load "greek-mode" nil t)
;;; or
;; (autoload 'greek-mode "greek-mode" "Switch to greek or latin input mode" t)
;; (autoload 'greek-toggle-accent "greek-mode" "Toggle accent of the character at pointer (if defined)" t)
;; (autoload 'greek-toggle-accent-advance "greek-mode" "Toggle accent of the character at pointer (if defined) and advance the pointer" t)
;; (autoload 'greek-toggle-char "greek-mode" "Convert written greek to/from latin" t)
;; (autoload 'greek-toggle-region "greek-mode" "Convert the region greek letters to/from latin letters." t)
;; (autoload 'greek-toggle-word "greek-mode" "Convert the letters of th following word (or ARG words) to/from greek/latin" t)
;; (autoload 'greek-replace-sigma "greek-mode" "Replace sigma at the end of each word in the region to terminal sigma." t)
;; (autoload 'allow-hi-bit "greek-mode" "Declare that the buffer can use 8bit characters" t)
;; (autoload 'allow-hi-bit-default "greek-mode" "Declare that new buffers can use 8bit characters" t)
;; (define-key esc-map "g" 'greek-mode)
;; (define-key esc-map "\"" 'greek-toggle-accent)
;; (define-key ctl-x-map "8" 'greek-toggle-word)
;; (if (eq window-system 'x) (setq default-ctl-arrow 8))

;; Version 1.0.1: aliases for << and >> where added, to ";<" ":<" ";>" and ":>"

(if (< (string-to-int (substring emacs-version 0 2)) 19)
    (error "Emacs 19 or later required"))

(provide 'greek-mode)

(defconst greek-alist-437
  '(("A" . ?\200) ("B" . ?\201) ("C" . ?\226) ("D" . ?\203)
    ("E" . ?\204) ("F" . ?\224) ("G" . ?\202) ("H" . ?\206)
    ("I" . ?\210) ("J" . ?\215) ("K" . ?\211) ("L" . ?\212)
    ("M" . ?\213) ("N" . ?\214) ("O" . ?\216) ("P" . ?\217)
    ("Q" . ?:)    ("R" . ?\220) ("S" . ?\221) ("T" . ?\222)
    ("U" . ?\207) ("V" . ?\227) ("W" . ?\355) ("X" . ?\225)
    ("Y" . ?\223) ("Z" . ?\205)
    ("a" . ?\230) ("b" . ?\231) ("c" . ?\257) ("d" . ?\233)
    ("e" . ?\234) ("f" . ?\255) ("g" . ?\232) ("h" . ?\236)
    ("i" . ?\240) ("j" . ?\245) ("k" . ?\241) ("l" . ?\242)
    ("m" . ?\243) ("n" . ?\244) ("o" . ?\246) ("p" . ?\247)
    ("q" . ?\;)   ("r" . ?\250) ("s" . ?\251) ("t" . ?\253)
    ("u" . ?\237) ("v" . ?\340) ("w" . ?\252) ("x" . ?\256)
    ("y" . ?\254) ("z" . ?\235)
    (";A" . ?\200) (";E" . ?\204) (";H" . ?\206) (";I" . ?\210)
    (";O" . ?\216) (";Y" . ?\223) (";V" . ?\227)
    (";a" . ?\341) (";e" . ?\342) (";h" . ?\343) (";i" . ?\345)
    (";o" . ?\346) (";y" . ?\347) (";v" . ?\351)
    (";;" . ?\354)
    (":I" . ?\210) (":Y" . ?\223)
    (":i" . ?\344) (":y" . ?\350)
    (";:i" . ?\352) (";:y" . ?\353)
    (":;i" . ?\352) (":;y" . ?\353)
    ("::" . ?:))
  "ISO-437 greek set")

(defconst greek-alist
  '(("A" . ?\301) ("B" . ?\302) ("C" . ?\330) ("D" . ?\304)
    ("E" . ?\305) ("F" . ?\326) ("G" . ?\303) ("H" . ?\307)
    ("I" . ?\311) ("J" . ?\316) ("K" . ?\312) ("L" . ?\313)
    ("M" . ?\314) ("N" . ?\315) ("O" . ?\317) ("P" . ?\320)
    ("Q" . ?:)    ("R" . ?\321) ("S" . ?\323) ("T" . ?\324)
    ("U" . ?\310) ("V" . ?\331) ("W" . ?\267) ("X" . ?\327)
    ("Y" . ?\325) ("Z" . ?\306)
    ("a" . ?\341) ("b" . ?\342) ("c" . ?\370) ("d" . ?\344)
    ("e" . ?\345) ("f" . ?\366) ("g" . ?\343) ("h" . ?\347)
    ("i" . ?\351) ("j" . ?\356) ("k" . ?\352) ("l" . ?\353)
    ("m" . ?\354) ("n" . ?\355) ("o" . ?\357) ("p" . ?\360)
    ("q" . ?\;)   ("r" . ?\361) ("s" . ?\363) ("t" . ?\364)
    ("u" . ?\350) ("v" . ?\371) ("w" . ?\362) ("x" . ?\367)
    ("y" . ?\365) ("z" . ?\346)
    (";A" . ?\266) (";E" . ?\270) (";H" . ?\271) (";I" . ?\272)
    (";O" . ?\274) (";Y" . ?\276) (";V" . ?\277)
    (";a" . ?\334) (";e" . ?\335) (";h" . ?\336) (";i" . ?\337)
    (";o" . ?\374) (";y" . ?\375) (";v" . ?\376)
    ("; " . ?\264)
    (":I" . ?\332) (":Y" . ?\333)
    (":i" . ?\372) (":y" . ?\373)
    (";:i" . ?\300) (";:y" . ?\340)
    (":;i" . ?\300) (":;y" . ?\340)
    (";<" . ?\253) (";>" . ?\273)
    (":<" . ?\253) (":>" . ?\273)
    (";;" . ?\;)
    ("::" . ?:))
  "ELOT-928 greek set")

(defconst greek-upcase
  '((";:i" . ":I") (";:y" . ":Y")
    (":i" . ":I") (":y" . ":Y")
    (";a" . ";A") (";e" . ";E") (";h" . ";H") (";i" . ";I")
    (";o" . ";O") (";y" . ";Y") (";v" . ";V")
    ("a" . "A") ("b" . "B") ("c" . "C") ("d" . "D")
    ("e" . "E") ("f" . "F") ("g" . "G") ("h" . "H")
    ("i" . "I") ("j" . "J") ("k" . "K") ("l" . "L")
    ("m" . "M") ("n" . "N") ("o" . "O") ("p" . "P")
    ("r" . "R") ("w" . "S") ("s" . "S") ("t" . "T")
    ("u" . "U") ("v" . "V") ("x" . "X")
    ("y" . "Y") ("z" . "Z"))
  "Greek lower case letters and their upper case counterparts")

(defvar greek-mode-map nil "Keymap used in greek-mode.")
(defvar greek-mode nil "Non nil if the buffer is in greek minor mode.")
(defvar greek-input-chars (make-string 256 0) "The latin->greek letter correspondance.")
(defvar greek-output-chars (make-vector 256 nil) "The greek->latin letter correspondance.")
(defvar greek-toggle-chars (make-vector 256 nil) "The latin/greek exchange letter correspondance.")
(defvar greek-toggle-vector nil "The latin/greek letter correspondance in use.")
(defvar greek-accent-to (make-string 256 0) "The letter greek-toggle-accent converts to")
(defvar greek-lc-sigma nil "The greek lower case sigma regexpr")
(defvar greek-te-sigma nil "The greek terminal sigma replacement")
(defvar greek-tex-normal nil "If greek/tex extensions will be used")
(defvar greek-latin-normal nil "If greek letters will be used after latin letters")
(defvar greek-sigma-normal nil "If greek terminal sigma -> sigma")

(defun greek-insert-init ()
  (if (and (null greek-sigma-normal)
	   (= (preceding-char) (aref greek-input-chars ?w)))
      (progn
	(delete-char -1)
	(insert (aref greek-input-chars ?s)))))

(defun greek-define-init (alist)
  "Greek sigma and accent initialization"
  (if greek-lc-sigma nil
    (setq greek-lc-sigma (concat (char-to-string (cdr (assoc "s" alist))) "\\>")))
  (if greek-te-sigma nil
    (setq greek-te-sigma (char-to-string (cdr (assoc "w" alist)))))
  (let ((list alist) elem buddy)
    (while list
      (setq elem (car list) list (cdr list))
      (if (= (aref (car elem) 0) ?\;)
	  (if (setq buddy (assoc (substring (car elem) 1) alist))
	      (let ((val (aref greek-accent-to (cdr elem))))
		(aset greek-accent-to (cdr elem) (aref greek-accent-to (cdr buddy)))
		(aset greek-accent-to (cdr buddy) val)))))))

(defun greek-define-key (elem)
  "Define the key that corresponds to the pair ELEM"
  (aset greek-toggle-chars (cdr elem) (car elem))
  (if (= (length (car elem)) 1)
      (aset greek-toggle-chars (string-to-char (car elem)) (cdr elem)))
  (aset greek-output-chars (cdr elem) (car elem))
  (if (= (length (car elem)) 1)
      (aset greek-input-chars (string-to-char (car elem)) (cdr elem)))
  (if (= (cdr elem) (aref greek-input-chars (string-to-char (substring (car elem) -1))))
      (if (and (= (length (car elem)) 1)
	       (= (char-syntax (string-to-char (car elem))) ?w))
	  (define-key greek-mode-map (car elem) 'greek-self-insert-alnum)
	(define-key greek-mode-map (car elem) 'greek-self-insert))
      (if (= (char-syntax (cdr elem)) ?w)
	  (define-key greek-mode-map (car elem) (list 'lambda () '(interactive) '(greek-insert-init) (list 'insert (cdr elem))))
	(define-key greek-mode-map (car elem) (list 'lambda () '(interactive) (list 'insert (cdr elem)))))
      ))

(defun standard-case-syntax-pair (uc lc)
  "Initialize the case-table definitions and set the entries for characters
UC and LC to indicate an (uppercase, lowercase) pair of letters."
  (modify-syntax-entry lc "w   " (standard-syntax-table))
  (modify-syntax-entry uc "w   " (standard-syntax-table))
  (modify-syntax-entry lc "w   " text-mode-syntax-table)
  (modify-syntax-entry uc "w   " text-mode-syntax-table)
  (if (and (boundp 'TeX-mode-syntax-table) TeX-mode-syntax-table)
      (progn
	(modify-syntax-entry lc "w   "  TeX-mode-syntax-table)
	(modify-syntax-entry uc "w   "  TeX-mode-syntax-table)))
  (if (and (< (string-to-int (substring emacs-version 3 5)) 29)
	   (< (string-to-int (substring emacs-version 0 2)) 20))
      (progn
	(aset (car (standard-case-table)) uc lc)
	(aset (car (standard-case-table)) lc lc)
	(aset (car (cdr (standard-case-table))) lc uc)
	(aset (car (cdr (standard-case-table))) uc uc))
    (aset (standard-case-table) uc lc)
    (aset (standard-case-table) lc lc)
    (aset (char-table-extra-slot (standard-case-table) 0) lc uc)
    (aset (char-table-extra-slot (standard-case-table) 0) uc uc)))

(defun greek-case-pair (elem)
  "Change the syntax table entries for the letters in ELEM"
  (standard-case-syntax-pair (cdr (assoc (cdr elem) greek-alist))
			     (cdr (assoc (car elem) greek-alist))))

(if (boundp 'standard-display-table) nil (defvar standard-display-table nil ""))
(if (assq 'greek-mode minor-mode-alist)
    nil
  (if standard-display-table nil
    (setq standard-display-table (make-display-table)))
  (let ((l 160) (h 254)) ; or 128 255
    (while (<= l h)
      (aset standard-display-table l (vector l))
      (setq l (1+ l))))
  (let ((i (length greek-accent-to)))
    (while (null (zerop (setq i (1- i)))) (aset greek-accent-to i i)))
  (make-variable-buffer-local 'greek-mode)
  (make-variable-buffer-local 'greek-old-map)
  (setq greek-mode-map (make-keymap))
  (mapcar 'greek-case-pair greek-upcase)
  (set-case-table (standard-case-table))
  (mapcar 'greek-define-key greek-alist)
  (greek-define-init greek-alist)
  (if greek-toggle-vector
      (if (symbolp greek-toggle-vector) (setq greek-toggle-vector (eval greek-toggle-vector)))
    (setq greek-toggle-vector greek-toggle-chars))
  (setq-default greek-mode nil)
  (setq minor-mode-alist (cons '(greek-mode " Greek") minor-mode-alist)))

;;;###autoload
(defun greek-mode (&optional arg)
  "Toggle greek input mode.
With ARG, turn greek mode on iff arg is positive.
In greek mode, characters typed in produce the corresponding greek codes."
  (interactive "P")
  (if greek-mode
      (use-local-map greek-old-map)
    (setq greek-old-map (current-local-map)))
  (if (setq greek-mode
	    (if (null arg) (not greek-mode)
	      (> (prefix-numeric-value arg) 0)))
      (use-local-map greek-mode-map))
  (set-buffer-modified-p (buffer-modified-p))) ;No-op, but updates mode line.

(defun greek-self-insert (arg)
  "Insert ARG times the greek letter corresponding to the key typed."
  (interactive "*p")
  (while (> arg 0)
    (insert (aref greek-input-chars last-command-char))
    (setq arg (1- arg))))

(defun greek-self-insert-alnum (arg)
  "Insert ARG times the greek letter corresponding to the key typed, or
the key pressed, if in tex-modes and the word at point starts with a \\."
  (interactive "*p")
  (if (or (and (= (char-syntax (preceding-char)) ?w)
	       (null (zerop (aref greek-input-chars (preceding-char))))
	       (null greek-latin-normal))
	  (and (memq major-mode '(plain-tex-mode latex-mode plain-TeX-mode LaTeX-mode))
	       (null greek-tex-normal)
	       (save-excursion
		 (if (= (char-syntax (preceding-char)) ?w) (forward-word -1))
		 (eq (preceding-char) ?\\))))
      (self-insert-command arg)
    (if (= (char-syntax (aref greek-input-chars last-command-char)) ?w)
	(greek-insert-init))
    (if (and (null greek-sigma-normal)
	     (= last-command-char ?s)
	     (null (and (= (char-syntax (following-char)) ?w)
			(zerop (aref greek-input-chars (following-char))))))
	(setq last-command-char ?w))
    (greek-self-insert arg)))

;;;###autoload
(defun greek-toggle-char ()
  "Convert written greek to/from latin and advance cursor"
  (interactive "*")
  (let ((c (char-after (point))))
    (if (if (stringp greek-toggle-vector)
	    (zerop (aref greek-toggle-vector c))
	  (null (aref greek-toggle-vector c)))
	(forward-char 1)
      (insert (aref greek-toggle-vector c))
      (delete-char 1))))

;;;###autoload
(defun greek-toggle-region (beg end)
  "Convert the region greek letters to/from latin letters.
In programs, wants two arguments.  These arguments specify the starting
and ending character numbers of the region to operate on.  When used as
a command, the text between point and the mark is operated on."
      (interactive "*r")
      (save-excursion
	(goto-char beg)
	(save-restriction
	  (narrow-to-region (point) end)
	  (while (null (eobp))
	    (let ((c (char-after (point))))
	      (if (if (stringp greek-toggle-vector)
		      (zerop (aref greek-toggle-vector c))
		    (null (aref greek-toggle-vector c)))
		  (forward-char 1)
		(insert (aref greek-toggle-vector c))
		(delete-char 1)))))))

;;;###autoload
(defun greek-toggle-word (arg)
  "Convert the letters of th following word (or ARG words) to/from greek/latin,
moving over. With negative argument, convert previous words but do not move."
  (interactive "*p")
  (if (< arg 0) 	
      (greek-toggle-region (save-excursion (forward-word arg) (point))
			       (point))
    (let ((pos (point))) 
      (forward-word arg) 	
      (greek-toggle-region pos (point)))))

;;;###autoload
(defun greek-replace-sigma (beg end)
  "Replace the greek letter sigma at the end of each word in the region
to the greek letter terminal sigma.
In programs, wants two arguments.  These arguments specify the starting
and ending character numbers of the region to operate on.  When used as
a command, the text between point and the mark is operated on."
      (interactive "*r")
      (save-excursion
	(goto-char beg)
	(save-restriction
	  (narrow-to-region (point) end)
	  (replace-regexp greek-lc-sigma greek-te-sigma nil))))

;;;###autoload
(defun greek-toggle-accent ()
  "Toggle accent of the character at pointer (if defined)"
  (interactive "*")
  (let ((c (char-after (point))))
    (if (= (aref greek-accent-to c) c) nil
      (insert (aref greek-accent-to c))
      (delete-char 1)
      (backward-char 1))))

;;;###autoload
(defun greek-toggle-accent-advance ()
  "Toggle accent of the character at pointer (if defined) and advance the pointer"
  (interactive "*")
  (let ((c (char-after (point))))
    (if (= (aref greek-accent-to c) c)
	(forward-char 1)
      (insert (aref greek-accent-to c))
      (delete-char 1))))

;;;###autoload
(defun greek-convert-region (beg end)
  "Convert the region greek letters to/from latin letters,
so that all characters are converted to the current input mode.
In programs, wants two arguments.  These arguments specify the starting
and ending character numbers of the region to operate on.  When used as
a command, the text between point and the mark is operated on."
      (interactive "*r")
      (let ((v (if greek-mode greek-input-chars greek-output-chars)))
	(save-excursion
	  (goto-char beg)
	  (save-restriction
	    (narrow-to-region (point) end)
	    (while (null (eobp))
	      (let ((c (char-after (point))))
		(if (if (stringp v)
			(zerop (aref v c))
		      (null (aref v c)))
		    (forward-char 1)
		  (insert (aref v c))
		  (delete-char 1))))))))

;;;###autoload
(defun greek-convert-word (arg)
  "Convert the letters of the following word (or ARG words) to/from greek/latin,
moving over. With negative argument, convert previous words but do not move."
  (interactive "*p")
  (if (< arg 0) 	
      (greek-convert-region (save-excursion (forward-word arg) (point))
			       (point))
    (let ((pos (point))) 
      (forward-word arg) 	
      (greek-convert-region pos (point)))))


; set by default -- included for backwards compatibility
(defun allow-hi-bit ()
  "Declare that the buffer can use 8bit characters"
  (interactive))

; set by default -- included for backwards compatibility
(defun allow-hi-bit-default ()
  "Declare that new buffers can use 8bit characters"
  (interactive))

(define-key esc-map "g" 'greek-mode)
(define-key esc-map "\"" 'greek-toggle-accent)
(define-key ctl-x-map "8" 'greek-toggle-word)
;; possible new bindings:
; (define-key esc-map "o" 'greek-mode)
; (define-key esc-map "n" 'greek-convert-word)
; (define-key esc-map "\"" 'greek-toggle-accent)
