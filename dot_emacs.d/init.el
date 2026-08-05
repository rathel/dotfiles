;;; init.el --- Personal Emacs configuration -*- lexical-binding: t; -*-

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
      (snow-storm-0 "#d8dee9")
      (snow-storm-1 "#e5e9f0")
      (snow-storm-2 "#eceff4")
      (frost-1 "#8fbcbb")
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
   `(font-lock-comment-face ((t (:foreground "#81a1c1"))))
   `(font-lock-keyword-face ((t (:foreground ,frost-3 :weight bold))))
   `(font-lock-function-name-face ((t (:foreground ,frost-2))))
   `(font-lock-variable-name-face ((t (:foreground ,aurora-purple))))
   `(font-lock-type-face ((t (:foreground ,aurora-yellow))))
   `(font-lock-constant-face ((t (:foreground ,aurora-orange))))
   `(font-lock-string-face ((t (:foreground ,aurora-green))))
   `(error ((t (:foreground ,aurora-red :weight bold))))
   `(warning ((t (:foreground ,aurora-yellow :weight bold))))))

;; Install and enable Evil from GNU ELPA when it is not already available.
(require 'package)
(setq package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
        ("melpa" . "https://melpa.org/packages/")))
(package-initialize)

(unless (package-installed-p 'evil)
  (condition-case err
      (progn
        (unless package-archive-contents
          (package-refresh-contents))
        (package-install 'evil))
    (error
     (message "Could not install Evil: %s" (error-message-string err)))))

(when (require 'evil nil t)
  (evil-mode 1))

;;; init.el ends here
