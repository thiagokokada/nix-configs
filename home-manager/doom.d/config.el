;;; ~/.doom.d/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here

;;; GENERAL

;; theme
(load-theme 'doom-vibrant t)

;; disable confirmation message on exit
(setq confirm-kill-emacs nil)

;; set window title with "[project] filename"
(setq frame-title-format
      (setq icon-title-format
            '(""
              (:eval
               (format "[%s] " (projectile-project-name)))
              "%b")))

;; font
(setq doom-font (font-spec :family "Hack" :size 18)
      doom-big-font-increment 2
      doom-unicode-font (font-spec :family "Noto Sans Mono"))

;; enable minibuffer to work correctly in evil mode
(setq evil-collection-setup-minibuffer t)

;; set localleader the same as Spacemacs
(setq doom-localleader-key ",")

;; general mappings
(map!
 ; remove default workspace shortcuts
 :n "C-t" #'better-jumper-jump-backward
 :n "C-S-t" nil
 ; move betweeen windows faster in normal mode
 :m "C-h" #'evil-window-left
 :m "C-j" #'evil-window-down
 :m "C-k" #'evil-window-up
 :m "C-l" #'evil-window-right
 ; move windows faster in normal mode
 :m "C-S-h" #'+evil/window-move-left
 :m "C-S-j" #'+evil/window-move-down
 :m "C-S-k" #'+evil/window-move-up
 :m "C-S-l" #'+evil/window-move-right
 ; misc
 :n "-" #'dired-jump
 :nv "C-a" #'evil-numbers/inc-at-pt
 :nv "C-S-a" #'evil-numbers/dec-at-pt
 :nv "C-SPC" #'+fold/toggle)

;; which-key
(setq which-key-idle-delay 0.4)

;; company
(setq company-selection-wrap-around t)

;; dired
(add-hook! dired-mode
  ;; Compress/Uncompress tar files
  (auto-compression-mode t)

  ;; Auto refresh buffers
  (global-auto-revert-mode t)

  ;; Also auto refresh dired, but be quiet about it
  (setq global-auto-revert-non-file-buffers t)
  (setq auto-revert-verbose nil)

  ;; Emulate vinegar.vim
  (setq dired-omit-verbose nil)
  (setq dired-hide-details-hide-symlink-targets nil)
  (make-local-variable 'dired-hide-symlink-targets)
  (dired-hide-details-mode t))

;; projectile
(after! projectile
  (defalias 'projectile-find-projects-in-directory 'projectile-discover-projects-in-directory)
  (defalias 'projectile-find-projects-in-search-path 'projectile-discover-projects-in-search-path)
  (setq projectile-enable-caching nil
        projectile-indexing-method 'alien)
  (map!
   (:leader
     (:map projectile-mode-map
       (:prefix ("p" . "project")
         :desc "Find implementation or test in other window"
         "A" #'projectile-find-implementation-or-test-other-window
         :desc "Replace literal"
         "C-r" #'projectile-replace
         :desc "Replace using regexp"
         "C-R" #'projectile-replace-regexp)))))

(defadvice projectile-project-root (around ignore-remote first activate)
    (unless (file-remote-p default-directory) ad-do-it))

;;; MAJOR MODES

;; adoc-mode
(use-package! adoc-mode
  :mode ("\\.adoc\\'"))

(use-package! clojure-mode
  :mode ("\\.repl\\'" "\\joker\\'")
  :init (setq cljr-warn-on-eval nil
              cljr-eagerly-build-asts-on-startup nil
              cider-show-error-buffer 'only-in-repl)
  :config
  (map!
   (:map (clojure-mode-map clojurescript-mode-map)
    (:n "R" #'hydra-cljr-help-menu/body)
    (:localleader
     ("=" #'clojure-align
      (:prefix ("e" . "eval")
       "n" #'cider-eval-ns-form))))))

(use-package! cider
  :after clojure-mode
  :config
  (set-lookup-handlers! 'cider-mode nil))

(use-package! clj-refactor
  :after clojure-mode
  :config
  (set-lookup-handlers! 'clj-refactor-mode nil))

;; graphql
(use-package! graphql-mode
  :mode ("\\.gql\\'" "\\.graphql\\'")
  :config (setq-hook! 'graphql-mode-hook tab-width graphql-indent-level))

;; hover
(use-package! hover
  :after dart-mode
  :config
  (setq hover-hot-reload-on-save t
        hover-clear-buffer-on-hot-restart t
        hover-screenshot-path "$HOME/Pictures")
  (set-popup-rule! "\\*Hover\\*" :quit nil)
  (defalias 'flutter-pub-get 'lsp-dart-pub-get)
  (defalias 'flutter-pub-upgrade 'lsp-dart-pub-upgrade)
  (defalias 'flutter-pub-outdated 'lsp-dart-pub-outdated))

;; lispyville
(use-package! lispyville
  :hook ((common-lisp-mode . lispyville-mode)
         (emacs-lisp-mode . lispyville-mode)
         (scheme-mode . lispyville-mode)
         (racket-mode . lispyville-mode)
         (hy-mode . lispyville-mode)
         (lfe-mode . lispyville-mode)
         (clojure-mode . lispyville-mode))
  :config
  (lispyville-set-key-theme
   '(additional
     additional-insert
     (additional-movement normal visual motion)
     (additional-wrap normal insert)
     (atom-movement normal visual)
     c-w
     c-u
     (commentary normal visual)
     escape
     (operators normal)
     (prettify insert)
     slurp/barf-cp)))

;; ix
(use-package! ix
  :defer t)

;; lsp
(defun find-path-by-executable (exec)
  (when-let (path (executable-find exec))
    (file-name-directory
     (directory-file-name
      (file-name-directory
       (file-chase-links path))))))

(use-package! lsp-mode
  ; https://emacs-lsp.github.io/lsp-mode/tutorials/how-to-turn-off/
  :init (setq lsp-modeline-code-actions-mode t
              lsp-enable-symbol-highlighting nil
              lsp-ui-doc-enable nil
              lsp-ui-doc-show-with-cursor nil
              lsp-ui-doc-show-with-mouse nil
              lsp-headerline-breadcrumb-enable nil
              lsp-signature-render-documentation nil
              lsp-python-ms-executable (executable-find "python-language-server")
              lsp-dart-sdk-dir (find-path-by-executable "dart")
              lsp-flutter-sdk-dir (find-path-by-executable "flutter")
              lsp-file-watch-threshold 10000)
  :config
  (advice-add #'lsp-rename :after (lambda (&rest _) (projectile-save-project-buffers)))
  (add-to-list 'lsp-language-id-configuration '(nix-mode . "nix"))
  (lsp-register-client
   (make-lsp-client :new-connection (lsp-stdio-connection '("rnix-lsp"))
                    :major-modes '(nix-mode)
                    :server-id 'nix)))

(add-hook! nix-mode #'lsp!)

;; sort-words
(use-package! sort-words
  :defer t)

;; uuidgen
(use-package! uuid-gen
  :defer t)

;;; MISC

;; load local configuration file if exists
(load! "local.el" "~/.config/doom" t)
