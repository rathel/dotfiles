;;; tokyonight-theme.el --- A dark tokyonight theme -*- lexical-binding: t; -*-

;;; Commentary:
;; A compact, readable dark theme matching the Tokyo Night palette used by
;; the rest of this Emacs configuration.

;;; Code:

(deftheme tokyonight
  "A dark tokyonight theme.")

(let ((class '((class color) (min-colors 89))))
  (custom-theme-set-faces
   'tokyonight
   `(default ((,class (:background "#1a1b26" :foreground "#c0caf5"))))
   `(cursor ((,class (:background "#7dcfff"))))
   `(fringe ((,class (:background "#1a1b26" :foreground "#7dcfff"))))
   `(region ((,class (:background "#33467c" :foreground "#e0e6ff"))))
   `(highlight ((,class (:background "#16161e"))))
   `(shadow ((,class (:foreground "#565f89"))))
   `(link ((,class (:foreground "#7dcfff" :underline t))))
   `(warning ((,class (:foreground "#e0af68" :weight bold))))
   `(error ((,class (:foreground "#f7768e" :weight bold))))
   `(success ((,class (:foreground "#7aa2f7" :weight bold))))

   ;; Mode lines and headers.
   `(mode-line ((,class (:background "#33467c" :foreground "#e0e6ff"
                                    :box nil :weight semi-bold))))
   `(mode-line-inactive ((,class (:background "#16161e" :foreground "#565f89"
                                             :box nil))))
   `(header-line ((,class (:background "#16161e" :foreground "#c0caf5"
                                       :box nil :weight semi-bold))))
   `(minibuffer-prompt ((,class (:foreground "#7dcfff" :weight bold))))

   ;; Syntax highlighting.
   `(font-lock-builtin-face ((,class (:foreground "#7dcfff"))))
   `(font-lock-comment-face ((,class (:foreground "#565f89" :slant italic))))
   `(font-lock-constant-face ((,class (:foreground "#e0af68"))))
   `(font-lock-doc-face ((,class (:foreground "#565f89"))))
   `(font-lock-function-name-face ((,class (:foreground "#7dcfff" :weight semi-bold))))
   `(font-lock-keyword-face ((,class (:foreground "#7dcfff" :weight bold))))
   `(font-lock-negation-char-face ((,class (:foreground "#f7768e" :weight bold))))
   `(font-lock-preprocessor-face ((,class (:foreground "#e0af68"))))
   `(font-lock-regexp-grouping-backslash ((,class (:foreground "#e0af68" :weight bold))))
   `(font-lock-regexp-grouping-construct ((,class (:foreground "#e0af68" :weight bold))))
   `(font-lock-string-face ((,class (:foreground "#e0e6ff"))))
   `(font-lock-type-face ((,class (:foreground "#7aa2f7"))))
   `(font-lock-variable-name-face ((,class (:foreground "#c0caf5"))))
   `(font-lock-warning-face ((,class (:foreground "#f7768e" :weight bold))))

   ;; Built-in interfaces.
   `(button ((,class (:foreground "#7dcfff" :underline t))))
   `(completions-common-part ((,class (:foreground "#7dcfff"))))
   `(completions-first-difference ((,class (:foreground "#f7768e" :weight bold))))
   `(dired-directory ((,class (:foreground "#7dcfff" :weight bold))))
   `(dired-flagged ((,class (:foreground "#f7768e" :weight bold))))
   `(dired-header ((,class (:foreground "#7aa2f7" :weight bold))))
   `(dired-mark ((,class (:foreground "#e0af68" :weight bold))))
   `(dired-marked ((,class (:foreground "#e0af68" :weight bold))))
   `(isearch ((,class (:background "#e0af68" :foreground "#1a1b26" :weight bold))))
   `(lazy-highlight ((,class (:background "#33467c" :foreground "#e0e6ff"))))
   `(match ((,class (:background "#33467c" :foreground "#e0e6ff" :weight bold))))
   `(show-paren-match ((,class (:background "#7aa2f7" :foreground "#1a1b26" :weight bold))))
   `(show-paren-mismatch ((,class (:background "#f7768e" :foreground "#1a1b26" :weight bold))))
   `(trailing-whitespace ((,class (:background "#f7768e"))))
   `(whitespace-space ((,class (:foreground "#33467c"))))
   `(whitespace-tab ((,class (:background "#16161e"))))

   ;; Org and Markdown.
   `(org-level-1 ((,class (:foreground "#e0e6ff" :weight bold :height 1.2))))
   `(org-level-2 ((,class (:foreground "#7dcfff" :weight bold :height 1.1))))
   `(org-level-3 ((,class (:foreground "#7aa2f7" :weight bold))))
   `(org-level-4 ((,class (:foreground "#e0af68" :weight bold))))
   `(org-link ((,class (:foreground "#7dcfff" :underline t))))
   `(markdown-header-face-1 ((,class (:foreground "#e0e6ff" :weight bold :height 1.2))))
   `(markdown-header-face-2 ((,class (:foreground "#7dcfff" :weight bold :height 1.1))))
   `(markdown-header-face-3 ((,class (:foreground "#7aa2f7" :weight bold))))
   `(markdown-link-face ((,class (:foreground "#7dcfff" :underline t))))
   `(markdown-inline-code-face ((,class (:foreground "#e0af68"))))

   ;; Diff and version-control faces.
   `(diff-added ((,class (:background "#1f3a35" :foreground "#9ece6a"))))
   `(diff-removed ((,class (:background "#3a202e" :foreground "#f7768e"))))
   `(diff-changed ((,class (:background "#3a3224" :foreground "#e0af68"))))
   `(diff-refine-added ((,class (:background "#33467c"))))
   `(diff-refine-removed ((,class (:background "#5f2a38"))))
   `(vc-conflict-state ((,class (:foreground "#f7768e" :weight bold))))
   `(vc-edited-state ((,class (:foreground "#e0af68"))))
   `(vc-locally-added-state ((,class (:foreground "#7aa2f7"))))
   `(vc-up-to-date-state ((,class (:foreground "#7dcfff"))))))

(custom-theme-set-variables
 'tokyonight
 '(ansi-color-names-vector ["#1a1b26" "#f7768e" "#7aa2f7" "#e0af68"
                            "#7dcfff" "#7aa2f7" "#7dcfff" "#e0e6ff"]))

(provide-theme 'tokyonight)

;;; tokyonight-theme.el ends here
