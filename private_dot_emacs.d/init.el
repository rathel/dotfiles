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

;; Vim-style relative line numbers: the current line is absolute, while
;; surrounding lines show their distance from it.
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1)

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

;; Install Evil and Markdown support from NonGNU ELPA when they are not available.
(require 'package)
(setq package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/"))
      package-archive-priorities '(("gnu" . 10) ("nongnu" . 5))
      package-pinned-packages '((evil . "nongnu"))
      package-selected-packages '(evil markdown-mode))
(package-initialize)

(dolist (package '(evil markdown-mode))
  (unless (package-installed-p package)
    (condition-case err
        (progn
          (unless package-archive-contents
            (package-refresh-contents))
          (package-install package))
      (error
       (message "Could not install %s: %s"
                package (error-message-string err))))))

(declare-function evil-mode "evil" (&optional arg))
(when (require 'evil nil t)
  (evil-mode 1))

;; Edit Markdown files with syntax highlighting and Markdown commands.
(when (require 'markdown-mode nil t)
  (add-to-list 'auto-mode-alist
               '("\\.\\(?:md\\|markdown\\)\\'" . markdown-mode)))

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

;; Yazi-like Dired: hjkl navigation, Space selection, and staged copy/cut/paste.
(defvar my-dired-clipboard nil
  "Files staged for the next Dired paste.")
(defvar my-dired-clipboard-action 'copy
  "Action to perform when pasting `my-dired-clipboard'.")

(defun my-dired-toggle-mark ()
  "Toggle the mark at point without moving point."
  (interactive)
  (when (dired-get-filename nil t)
    (let ((position (point)))
      (if (eq (char-after (line-beginning-position)) dired-marker-char)
          (dired-unmark 1)
        (dired-mark 1))
      (goto-char position))))

(defun my-dired-yank ()
  "Stage marked files for copying."
  (interactive)
  (setq my-dired-clipboard (dired-get-marked-files)
        my-dired-clipboard-action 'copy)
  (message "Yanked %d item%s for copying"
           (length my-dired-clipboard)
           (if (= (length my-dired-clipboard) 1) "" "s")))

(defun my-dired-cut ()
  "Stage marked files for moving."
  (interactive)
  (setq my-dired-clipboard (dired-get-marked-files)
        my-dired-clipboard-action 'move)
  (message "Cut %d item%s for moving"
           (length my-dired-clipboard)
           (if (= (length my-dired-clipboard) 1) "" "s")))

(defun my-dired-paste ()
  "Paste the staged files into the current Dired directory."
  (interactive)
  (unless my-dired-clipboard
    (user-error "Dired clipboard is empty"))
  (let* ((target (dired-current-directory))
         (files my-dired-clipboard)
         (moving (eq my-dired-clipboard-action 'move))
         (name-constructor
          (lambda (old-name)
            (expand-file-name
             (file-name-nondirectory (directory-file-name old-name))
             target))))
    (dired-create-files
     (if moving #'rename-file #'dired-copy-file)
     (if moving "Move" "Copy")
     files name-constructor (if moving ?M ?C))
    (when moving
      (setq my-dired-clipboard nil))
    (message "%s %d item%s into %s"
             (if moving "Moved" "Pasted")
             (length files)
             (if (= (length files) 1) "" "s")
             target)))

(with-eval-after-load 'dired
  (require 'dired-aux)

  ;; Navigation.
  (define-key dired-mode-map (kbd "h") #'dired-up-directory)
  (define-key dired-mode-map (kbd "j") #'dired-next-line)
  (define-key dired-mode-map (kbd "k") #'dired-previous-line)
  (define-key dired-mode-map (kbd "l") #'dired-find-file)

  ;; Selection and file operations.
  (define-key dired-mode-map (kbd "SPC") #'my-dired-toggle-mark)
  (define-key dired-mode-map (kbd "u") #'dired-unmark)
  (define-key dired-mode-map (kbd "a") #'dired-create-directory)
  (define-key dired-mode-map (kbd "r") #'dired-do-rename)
  (define-key dired-mode-map (kbd "d") #'dired-flag-file-deletion)
  (define-key dired-mode-map (kbd "D") #'dired-do-flagged-delete)
  (define-key dired-mode-map (kbd "y") #'my-dired-yank)
  (define-key dired-mode-map (kbd "x") #'my-dired-cut)
  (define-key dired-mode-map (kbd "p") #'my-dired-paste)

  ;; gg goes to the top, G to the bottom, and gr refreshes.
  (define-prefix-command 'my-dired-g-map)
  (define-key dired-mode-map (kbd "g") #'my-dired-g-map)
  (define-key my-dired-g-map (kbd "g") #'beginning-of-buffer)
  (define-key my-dired-g-map (kbd "r") #'revert-buffer)
  (define-key dired-mode-map (kbd "G") #'end-of-buffer)

  ;; Make the same bindings active in Evil's normal state.
  (with-eval-after-load 'evil
    (evil-define-key 'normal dired-mode-map
      (kbd "h") #'dired-up-directory
      (kbd "j") #'dired-next-line
      (kbd "k") #'dired-previous-line
      (kbd "l") #'dired-find-file
      (kbd "SPC") #'my-dired-toggle-mark
      (kbd "u") #'dired-unmark
      (kbd "a") #'dired-create-directory
      (kbd "r") #'dired-do-rename
      (kbd "d") #'dired-flag-file-deletion
      (kbd "D") #'dired-do-flagged-delete
      (kbd "y") #'my-dired-yank
      (kbd "x") #'my-dired-cut
      (kbd "p") #'my-dired-paste
      (kbd "g g") #'beginning-of-buffer
      (kbd "g r") #'revert-buffer
      (kbd "G") #'end-of-buffer)))

;;; init.el ends here
