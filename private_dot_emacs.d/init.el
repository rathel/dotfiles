;;; init.el --- Personal Emacs configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; Minimal Nord-themed Emacs setup with Evil and Eshell.

;;; Code:

;; Keep generated Custom state out of this managed init file.
(setq custom-file (locate-user-emacs-file "custom.el"))
(when (file-readable-p custom-file)
  (load custom-file nil 'nomessage))

;; Keep Emacs focused on the buffer by hiding the traditional chrome.
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-startup-screen t
      inhibit-startup-message t
      visible-bell t)

;; Nord - Polar Night palette.
(let ((polar-night-0 "#2e3440")
      (polar-night-1 "#3b4252")
      (polar-night-2 "#434c5e")
      (polar-night-3 "#4c566a")
      (snow-storm-1 "#e5e9f0")
      (snow-storm-2 "#eceff4")
      (frost-2 "#88c0d0")
      (frost-3 "#81a1c1")
      (aurora-red "#bf616a")
      (aurora-orange "#d08770")
      (aurora-yellow "#ebcb8b")
      (aurora-green "#a3be8c")
      (aurora-purple "#b48ead"))
  (custom-set-faces
   `(default ((t (:background ,polar-night-0 :foreground ,snow-storm-1))))
   `(cursor ((t (:background ,frost-2))))
   `(fringe ((t (:background ,polar-night-0 :foreground ,polar-night-3))))
   `(region ((t (:background ,polar-night-2))))
   `(highlight ((t (:background ,polar-night-1))))
   `(mode-line ((t (:background ,polar-night-2 :foreground ,snow-storm-2 :box nil))))
   `(mode-line-inactive ((t (:background ,polar-night-1 :foreground ,polar-night-3 :box nil))))
   `(minibuffer-prompt ((t (:foreground ,frost-2 :weight bold))))
   `(link ((t (:foreground ,frost-2 :underline t))))
   `(font-lock-comment-face ((t (:foreground ,frost-3))))
   `(font-lock-keyword-face ((t (:foreground ,frost-3 :weight bold))))
   `(font-lock-function-name-face ((t (:foreground ,frost-2))))
   `(font-lock-variable-name-face ((t (:foreground ,aurora-purple))))
   `(font-lock-type-face ((t (:foreground ,aurora-yellow))))
   `(font-lock-constant-face ((t (:foreground ,aurora-orange))))
   `(font-lock-string-face ((t (:foreground ,aurora-green))))
   `(error ((t (:foreground ,aurora-red :weight bold))))
   `(warning ((t (:foreground ,aurora-yellow :weight bold))))))

;; Install stable Evil from NonGNU ELPA when it is not available.
(require 'package)
(setq package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/"))
      package-archive-priorities '(("gnu" . 10) ("nongnu" . 5))
      package-pinned-packages '((evil . "nongnu"))
      package-selected-packages '(evil))
(package-initialize)

(unless (package-installed-p 'evil)
  (condition-case err
      (progn
        (unless package-archive-contents
          (package-refresh-contents))
        (package-install 'evil))
    (error
     (message "Could not install Evil: %s" (error-message-string err)))))

(declare-function evil-mode "evil" (&optional arg))
(when (require 'evil nil t)
  (evil-mode 1))

;; Built-in Eshell with persistent, deduplicated history.
(defvar eshell-history-size)
(defvar eshell-hist-ignoredups)
(defvar eshell-save-history-on-exit)
(defvar eshell-buffer-maximum-lines)
(defvar eshell-scroll-to-bottom-on-input)
(declare-function eshell-truncate-buffer "esh-mode" ())

(global-set-key (kbd "C-c e") #'eshell)

(with-eval-after-load 'em-hist
  (setq eshell-history-size 10000
        eshell-hist-ignoredups t
        eshell-save-history-on-exit t))

(with-eval-after-load 'esh-mode
  (setq eshell-buffer-maximum-lines 10000
        eshell-scroll-to-bottom-on-input 'this)
  (add-hook 'eshell-output-filter-functions #'eshell-truncate-buffer))

;;; init.el ends here
