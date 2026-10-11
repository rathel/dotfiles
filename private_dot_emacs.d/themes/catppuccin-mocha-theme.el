;;; catppuccin-mocha-theme.el --- A dark catppuccin-mocha theme -*- lexical-binding: t; -*-

;;; Commentary:
;; A compact, readable dark theme matching the Catppuccin Mocha palette used by
;; the rest of this Emacs configuration.

;;; Code:

(deftheme catppuccin-mocha
  "A dark catppuccin-mocha theme.")

(let ((class '((class color) (min-colors 89))))
  (custom-theme-set-faces
   'catppuccin-mocha
   `(default ((,class (:background "#1e1e2e" :foreground "#cdd6f4"))))
   `(cursor ((,class (:background "#74c7ec"))))
   `(fringe ((,class (:background "#1e1e2e" :foreground "#74c7ec"))))
   `(region ((,class (:background "#45475a" :foreground "#bac2de"))))
   `(highlight ((,class (:background "#181825"))))
   `(shadow ((,class (:foreground "#6c7086"))))
   `(link ((,class (:foreground "#74c7ec" :underline t))))
   `(warning ((,class (:foreground "#f9e2af" :weight bold))))
   `(error ((,class (:foreground "#f38ba8" :weight bold))))
   `(success ((,class (:foreground "#89b4fa" :weight bold))))

   ;; Mode lines and headers.
   `(mode-line ((,class (:background "#45475a" :foreground "#bac2de"
                                    :box nil :weight semi-bold))))
   `(mode-line-inactive ((,class (:background "#181825" :foreground "#6c7086"
                                             :box nil))))
   `(header-line ((,class (:background "#181825" :foreground "#cdd6f4"
                                       :box nil :weight semi-bold))))
   `(minibuffer-prompt ((,class (:foreground "#74c7ec" :weight bold))))

   ;; Syntax highlighting.
   `(font-lock-builtin-face ((,class (:foreground "#74c7ec"))))
   `(font-lock-comment-face ((,class (:foreground "#6c7086" :slant italic))))
   `(font-lock-constant-face ((,class (:foreground "#f9e2af"))))
   `(font-lock-doc-face ((,class (:foreground "#6c7086"))))
   `(font-lock-function-name-face ((,class (:foreground "#74c7ec" :weight semi-bold))))
   `(font-lock-keyword-face ((,class (:foreground "#74c7ec" :weight bold))))
   `(font-lock-negation-char-face ((,class (:foreground "#f38ba8" :weight bold))))
   `(font-lock-preprocessor-face ((,class (:foreground "#f9e2af"))))
   `(font-lock-regexp-grouping-backslash ((,class (:foreground "#f9e2af" :weight bold))))
   `(font-lock-regexp-grouping-construct ((,class (:foreground "#f9e2af" :weight bold))))
   `(font-lock-string-face ((,class (:foreground "#bac2de"))))
   `(font-lock-type-face ((,class (:foreground "#89b4fa"))))
   `(font-lock-variable-name-face ((,class (:foreground "#cdd6f4"))))
   `(font-lock-warning-face ((,class (:foreground "#f38ba8" :weight bold))))

   ;; Built-in interfaces.
   `(button ((,class (:foreground "#74c7ec" :underline t))))
   `(completions-common-part ((,class (:foreground "#74c7ec"))))
   `(completions-first-difference ((,class (:foreground "#f38ba8" :weight bold))))
   `(dired-directory ((,class (:foreground "#74c7ec" :weight bold))))
   `(dired-flagged ((,class (:foreground "#f38ba8" :weight bold))))
   `(dired-header ((,class (:foreground "#89b4fa" :weight bold))))
   `(dired-mark ((,class (:foreground "#f9e2af" :weight bold))))
   `(dired-marked ((,class (:foreground "#f9e2af" :weight bold))))
   `(isearch ((,class (:background "#f9e2af" :foreground "#1e1e2e" :weight bold))))
   `(lazy-highlight ((,class (:background "#45475a" :foreground "#bac2de"))))
   `(match ((,class (:background "#45475a" :foreground "#bac2de" :weight bold))))
   `(show-paren-match ((,class (:background "#89b4fa" :foreground "#1e1e2e" :weight bold))))
   `(show-paren-mismatch ((,class (:background "#f38ba8" :foreground "#1e1e2e" :weight bold))))
   `(trailing-whitespace ((,class (:background "#f38ba8"))))
   `(whitespace-space ((,class (:foreground "#45475a"))))
   `(whitespace-tab ((,class (:background "#181825"))))

   ;; Org and Markdown.
   `(org-level-1 ((,class (:foreground "#bac2de" :weight bold :height 1.2))))
   `(org-level-2 ((,class (:foreground "#74c7ec" :weight bold :height 1.1))))
   `(org-level-3 ((,class (:foreground "#89b4fa" :weight bold))))
   `(org-level-4 ((,class (:foreground "#f9e2af" :weight bold))))
   `(org-link ((,class (:foreground "#74c7ec" :underline t))))
   `(markdown-header-face-1 ((,class (:foreground "#bac2de" :weight bold :height 1.2))))
   `(markdown-header-face-2 ((,class (:foreground "#74c7ec" :weight bold :height 1.1))))
   `(markdown-header-face-3 ((,class (:foreground "#89b4fa" :weight bold))))
   `(markdown-link-face ((,class (:foreground "#74c7ec" :underline t))))
   `(markdown-inline-code-face ((,class (:foreground "#f9e2af"))))

   ;; Diff and version-control faces.
   `(diff-added ((,class (:background "#313244" :foreground "#a6e3a1"))))
   `(diff-removed ((,class (:background "#313244" :foreground "#f38ba8"))))
   `(diff-changed ((,class (:background "#313244" :foreground "#f9e2af"))))
   `(diff-refine-added ((,class (:background "#45475a"))))
   `(diff-refine-removed ((,class (:background "#45475a"))))
   `(vc-conflict-state ((,class (:foreground "#f38ba8" :weight bold))))
   `(vc-edited-state ((,class (:foreground "#f9e2af"))))
   `(vc-locally-added-state ((,class (:foreground "#89b4fa"))))
   `(vc-up-to-date-state ((,class (:foreground "#74c7ec"))))))

(custom-theme-set-variables
 'catppuccin-mocha
 '(ansi-color-names-vector ["#1e1e2e" "#f38ba8" "#89b4fa" "#f9e2af"
                            "#74c7ec" "#89b4fa" "#74c7ec" "#bac2de"]))

(provide-theme 'catppuccin-mocha)

;;; catppuccin-mocha-theme.el ends here
