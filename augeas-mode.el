;;; augeas-mode.el --- Augeas editing -*- lexical-binding: t; -*-

;; Copyright (C) 2015 Stefan Moeding

;; Author: Stefan Moeding <stm@kill-9.net>
;; URL: https://github.com/smoeding/emacs-augeas-mode
;; Time-stamp: <2017-03-22 19:01:03 stm>
;; Keywords: languages
;; Version: 0.0.2

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; This package implements a major mode for editing Augeas code.
;;
;; To use, put this file in your library path. Put this in your init file
;; (e.g. `~/.emacs.d/init.el'):
;;
;; (autoload 'augeas-mode "augeas-mode"
;;           "Major mode for editing augeas files." t)
;;
;; (add-to-list 'auto-mode-alist '("\\.aug\\'" . augeas-mode))
;;

;;; Change Log:
;;
;; 2017-03-22 stm
;;     Implement syntax-propertize-function to fontify regex/strings
;;
;; 2015-01-12 stm
;;     Initial version.
;;

;;; Code:

(require 'rx)

(defgroup augeas nil
  "Major mode for editing Augeas code."
  :link '(custom-group-link :tag "Font Lock Faces group" font-lock-faces)
  :prefix "augeas-"
  :group 'languages)

(defcustom augeas-compile-command "augparse -I. -I.."
  "Command to use when checking Augeas code."
  :type 'string
  :group 'augeas)

(defun augeas-mode-compilation-buffer-name (&rest _)
  "Return the name of Augeas compilation buffer."
  "*augparse*")

(defcustom augeas-mode-comment-start "(*"
  "Comments in `augeas-mode' start with this characters."
  :type 'string
  :group 'augeas)

(defcustom augeas-mode-comment-end "*)"
  "Comments in `augeas-mode' end with this characters."
  :type 'string
  :group 'augeas)

(defvar augeas-mode-syntax-table
  (let ((st (make-syntax-table)))
    (modify-syntax-entry ?_ "w"    st)
    (modify-syntax-entry ?\( "()1" st)
    (modify-syntax-entry ?\) ")(4" st)
    (modify-syntax-entry ?* ". 23" st)
    st)
  "Syntax table used when in `augeas-mode'.")

(defvar augeas-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-j") 'newline-and-indent)
    (define-key map (kbd "C-m") 'newline-and-indent)
    map)
  "Keymap for Augeas mode.")

(defconst augeas-keywords-regexp
  (regexp-opt '("after" "autoload" "in" "lens" "let" "module" "regexp"
                "string" "test")
              'words)
  "Keywords to highlight in Augeas mode.")

(defconst augeas-builtin-regexp
  (regexp-opt '("clear" "counter" "del" "excl" "get" "getenv" "incl"
                "insa" "insb" "key" "label" "lens_atype" "lens_ctype"
                "lens_format_atype" "lens_ktype" "lens_vtype"
                "print_endline" "print_regexp" "print_string" "print_tree"
                "read_file" "regexp_match" "replace-match" "seq" "set"
                "store" "transform" "value")
              'words)
  "Builtins to highlight in Augeas mode.")

(defvar augeas-font-lock-keywords
  `((,augeas-keywords-regexp . font-lock-keyword-face)
    (,augeas-builtin-regexp . font-lock-builtin-face)
    ("\\<module +\\([A-Z][A-Za-z0-9_]*\\)\\>" 1 font-lock-function-name-face)
    ("\\<test +\\([A-Za-z0-9._]*\\)\\>" 1 font-lock-function-name-face)
    ("\\<[A-Z][A-Za-z0-9_]*\\.[a-z][A-Za-z0-9_]+\\>" . font-lock-constant-face)
    ("\\<[a-z][A-Za-z0-9_]*\\>" . font-lock-variable-name-face))
  "Keywords used to highlight in Augeas mode.")

(defun augeas-syntax-propertize-function (start end)
  "Add syntax properties for augeas-mode between START and END."
  (funcall
   (syntax-propertize-rules
    ;; quoted strings enclosed in "..."
    ((rx (group "\"")                        ; start with a quote
         (*? (| (seq "\\" anything)          ; any escaped character or
                (not (in ?\" "\\"))))        ; anything else except these
         (group "\""))
     (1 "|") (2 "|"))                        ; finish with a quote
    ;; regular expressions enclosed in /.../
    ((rx (group "/")                         ; start with a slash
         (*? (| (seq "\\" anything)          ; any escaped character or
                (seq "["                     ; a character class containing
                     (*? (| (seq "\\" anything) ; any escaped character or
                            (not (in "]"))))    ; anything else except a ]
                     "]")                    ; or
                (not (in "/" "\\" "["))))    ; anything except these
         (group "/"))
     (1 "|") (2 "|"))
    ;; comments enclosed in (* ... *)
    ((rx (group "(*")                        ; comment start
         (*? anything)
         (group "*)"))                       ; comment end
     (1 "!") (2 "!")))
   start end))

(defalias 'augeas-parent-mode
  (if (fboundp 'prog-mode) 'prog-mode 'fundamental-mode)
  "The major mode used as parent mode for `augeas-mode'.

Either `prog-mode' if available or `fundamental-mode' otherwise.")


;;;###autoload
(define-derived-mode augeas-mode augeas-parent-mode "Augeas"
  "Major mode for editing augeas files.

Turning on Augeas mode runs the normal hook `augeas-mode-hook'.

\\{augeas-mode-map}"
  (use-local-map augeas-mode-map)
  (set-syntax-table (make-syntax-table augeas-mode-syntax-table))

  ;; Compilation
  (set (make-local-variable 'compilation-buffer-name-function)
       'augeas-mode-compilation-buffer-name)
  (set (make-local-variable 'compile-command)
       (concat augeas-compile-command " " (buffer-file-name)))

  ;; Font lock
  (set (make-local-variable 'font-lock-defaults) '(augeas-font-lock-keywords))
  (set (make-local-variable 'syntax-propertize-function)
       #'augeas-syntax-propertize-function)

  (set (make-local-variable 'require-final-newline) mode-require-final-newline)

  ;; Comments
  (set (make-local-variable 'comment-start) augeas-mode-comment-start)
  (set (make-local-variable 'comment-end) augeas-mode-comment-end))

(provide 'augeas-mode)

;;; augeas-mode.el ends here
