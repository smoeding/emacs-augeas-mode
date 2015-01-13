;;; augeas-mode.el --- Augeas editing

;; Copyright (C) 2015 Stefan Moeding

;; Author: Stefan Moeding <stm@kill-9.net>
;; URL: https://github.com/smoeding/emacs-augeas-mode
;; Time-stamp: <2015-01-13 17:31:24 stm>
;; Keywords: languages
;; Version: 0.0.1

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
;; 2015-01-12 stm
;;     Initial version.
;;

;;; Code:

(defgroup augeas nil
  "Major mode for editing Augeas code."
  :link '(custom-group-link :tag "Font Lock Faces group" font-lock-faces)
  :prefix "augeas-"
  :group 'languages)

(defvar augeas-mode-syntax-table
  (let ((st (make-syntax-table)))
      (modify-syntax-entry ?_ "w"    st)
      (modify-syntax-entry ?\( ". 1" st)
      (modify-syntax-entry ?\) ". 4" st)
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
    ("\\<Util\\.[A-Za-z_]+\\>" . font-lock-constant-face)
    ("\\<[a-z][A-Za-z0-9_]*\\>" . font-lock-variable-name-face)))

(defalias 'augeas-parent-mode
  (if (fboundp 'prog-mode) 'prog-mode 'fundamental-mode)
  "The mode used as parent mode for `augeas-mode'.

Either `prog-mode' if available or `fundamental-mode' otherwise.")


;;;###autoload
(define-derived-mode augeas-mode augeas-parent-mode "Augeas"
  "Major mode for editing augeas files.

\\{augeas-mode-map}
Turning on Augeas mode runs the normal hook `augeas-mode-hook'.

Key bindings:
\\{augeas-mode-map}"
  (use-local-map augeas-mode-map)
  (set-syntax-table (make-syntax-table augeas-mode-syntax-table))

  (set (make-local-variable 'font-lock-defaults) '(augeas-font-lock-keywords))
  (set (make-local-variable 'require-final-newline) mode-require-final-newline)

  (set (make-local-variable 'comment-start) "(*")
  (set (make-local-variable 'comment-end) "*)"))

(provide 'augeas-mode)

;;; augeas-mode.el ends here
