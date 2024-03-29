;; My Emacs Config

;; TODO: Still need to set up any web mode stuff
;; would like to see about just going the vscode htmlserver lsp route if
;; possible there...

;; Use M-x describe-personal-keybindings to see
;; what my keybinds are...

;; Add extra modules/directories to load path
;; should they be needed
(add-to-list 'load-path (expand-file-name "modules" user-emacs-directory))
(add-to-list 'load-path (expand-file-name "vendor" user-emacs-directory))

(setq gc-cons-threshold (* 128 1024 1024)
      comp-async-report-warnings-errors nil
      native-comp-async-report-warnings-errors nil

      inhibit-startup-screen t
      inhibit-startup-message t
      visible-bell t)

(tool-bar-mode -1)
;; (menu-bar-mode -1)
(global-visual-line-mode)

(global-auto-revert-mode)

(fset 'yes-or-no-p 'y-or-n-p)

;; Deal with the custom.el stuff
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))

;; Straight package manager config
(setq straight-use-package-by-default t)
(defvar bootstrap-version)
(let ((bootstrap-file (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent
         'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)

(use-package vterm
             :bind
             ("C-c v" . vterm-other-window))


;; Hydra
(use-package hydra)

;; use-package-hydra
;; - intregrate hydra with use-package
(use-package use-package-hydra
  :after hydra)

;; YAML Settings
(use-package yaml-mode)

;; Global Line Numbers
(require 'display-line-numbers)

(defcustom display-line-numbers-exempt-modes
  '(vterm-mode
    eshell-mode
    shell-mode
    term-mode
    ansi-term-mode
    treemacs-mode
    neotree-mode)
  "Major modes on which to disable the linum mode, exempts them from global requirement."
  :group 'display-line-numbers
  :type 'list
  :version "green")

(defun display-line-numbers--turn-on ()
  "Turn on line numbers but exempt certain major modes defined in `display-line-numbers-exempt-modes'"
  (if (and (not (member major-mode display-line-numbers-exempt-modes))
           (not (minibufferp)))
      (display-line-numbers-mode)))

(global-display-line-numbers-mode)


;; Save point location on buffer close
(save-place-mode t)

;; File backups and autosave
(defvar --backup-directory (concat user-emacs-directory "backups"))

(if (not (file-exists-p --backup-directory))
    (make-directory --backup-directory))

(setq backup-directory-alist `(("." . ,--backup-directory))
      make-backup-files t
      backup-by-copying t
      version-control t
      delete-old-versions t
      delete-by-moving-to-trash t
      kept-old-versions 6
      kept-new-versions 9
      auto-save-default t
      auto-save-timeout 20
      auto-save-interval 200)

;; Set the font
;; yay ttc-iosevka-ss14
(set-face-attribute 'default nil
                    ;; :font "FantasqueSansMono Nerd Font")
                    ;; :font "Iosevka SS14"
                    :font "SF Mono")


;; All the icons
(use-package all-the-icons) ;; M-x all-the-icons-install-fonts

;; Theming
;; Modus Themes
(use-package modus-themes
  :ensure
  :init
  ;; customizations prior to loading the theme
  (setq modus-themes-italic-constructs t
        modus-themes-bold-constructs t
        modus-themes-mixed-fonts t
        modus-themes-subtle-line-numbers t
        modus-themes-intense-markup t
        modus-themes-paren-match '(bold intense))
  ;; load theme files before enabling theme
  (modus-themes-load-themes)
  :config
  ;; load theme of choice
  (modus-themes-load-vivendi))

(use-package solaire-mode
  :hook
  (change-major-mode . turn-on-solaire-mode)

  :config
  (solaire-global-mode t))

;; (use-package doom-themes
;;   :config
;;   (setq doom-themes-enable-bold t
;; 	doom-themes-enable-italic t)
;;   (load-theme 'doom-acario-dark t)
;;   (doom-themes-visual-bell-config))

(use-package doom-modeline
  :config
  (doom-modeline-mode t)
  (setq doom-modeline-window-width-limit fill-column))

;; Helpful help
;; Much better help system than the default
(use-package helpful
  :bind
  ("C-h f" . helpful-callable)
  ("C-h v" . helpful-variable)
  ("C-h k" . helpful-key)
  ("C-h C-d" . helpful-at-point))

;; Which key
;; Shows what follows keybind after a delay
(use-package which-key
  :config
  (which-key-mode))

;; Command completion system
;; Vertico, Marginalia, Consult, Orderless
;; vertico - basic command completion (simpler helm)
(use-package vertico
  :bind
  (:map minibuffer-local-map
        ("<left>" . backward-kill-word))  ;; use left arrow to "traverse" directory
  :custom
  (vertico-cycle t)  ;; go back to top when you reach the bottom of selection list
  :init
  (vertico-mode))

;; orderless - "fuzzy" matching more or less
(use-package orderless
  :init
  (setq completion-styles '(orderless)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

(use-package savehist
  :init
  (savehist-mode))

;; marginalia - describe what the commands are
(use-package marginalia
  :after
  vertico

  :bind
  (("M-A" . marginalia-cycle)
   :map minibuffer-local-map
   ("M-A" . marginalia-cycle))

  :custom
  (marginalia-annotators '(marginalia-annotators-heavy marginalia-annotators-light nil))

  :init
  (marginalia-mode))

;; consult - badassery all around
;; look into `consult-yank-from-kill-ring'
(use-package consult
  :bind
  (("C-x b" . consult-buffer)  ;; Better buffer swap, with preview
   ("C-s" . consult-line)      ;; Cool searching replacement
   ("C-c h" . consult-history)
   ("C-c y" . consult-yank-from-kill-ring)
   ("C-c r" . consult-ripgrep)) ;; Killer grep in directories/projects

  :hook
  (completion-list-mode . consult-preview-at-point-mode)

  :init
  (setq register-preview-delay 0
        register-preview-function #'consult-register-format)

  :config
  (setq consult-project-root-function 'projectile-project-root))

(use-package embark
  :bind
  (("C-." . embark-act)
   ("C-;" . embark-dwim)
   ("C-h B" . embark-bindings))  ;; show all bindings

  :config
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

(use-package embark-consult
  :after (embark consult)
  :demand t
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))


;; Projectile
(use-package projectile
             :init
             (projectile-mode 1)

             :bind
             (:map projectile-mode-map
                   ("C-c p" . projectile-command-map)))

;; nex3/perspective-el
;; Perspective application
(use-package perspective
  :after
  consult

  :bind
  ;; switch from the default buffer list to...
  (("C-x C-b" . persp-list-buffers)
   ;; persp-kill-buffer* uses `completing-read' to list all buffers
   ("C-x k" . persp-kill-buffer*))

  :custom
  (persp-mode-prefix-key (kbd "C-c M-p"))
  (persp-sort 'created) ;; or access, name

  :init
  (persp-mode)
  ;; ..recall that we use `consult' : "C-x b"
  ;; .. so use perspective as a source for buffer list
  (consult-customize consult--source-buffer :hidden t :default nil)
  (add-to-list 'consult-buffer-sources persp-consult-source))

;; Dashboard settings
(use-package dashboard
             :init
             (setq dashboard-startup-banner 'logo
                   dashboard-set-heading-icons t
                   dashboard-set-file-icons t
                   dashboard-projects-backend 'projectile
                   dashboard-items '((recents . 5)
                                     (projects . 5))

                   ;; When using daemon mode, the default buffer
                   ;; is *scratch*. I don't want that.
                   initial-buffer-choice (lambda () (get-buffer "*dashboard*")))
             :config
             (dashboard-setup-startup-hook))

;; ACE Window
(use-package ace-window
             :config
             (global-set-key (kbd "M-o") 'ace-window))

;; Treemacs Related Stuff
(use-package treemacs
  :bind
  (:map global-map ("M-0" . treemacs-select-window))

  ;; Uncomment the following to have treemacs only show the current project
  :custom
  (treemacs-project-follow-mode 1)

  :config
  (setq treemacs-git-mode 'deferred
        treemacs-follow-mode t
        treemacs-project-follow-cleanup t
        treemacs-filewatch-mode t
        treemacs-is-never-other-window t))

(use-package treemacs-projectile
  :after treemacs projectile)

;; Treemacs icons (any...) and
;; yasnippet do not play nicely
;; if using yasnippet, then treemacs does
;; not display icons properly, nor
;; does it do directory compaction
(use-package treemacs-all-the-icons
  :after treemacs all-the-icons)

(use-package treemacs-icons-dired
  :after treemacs dired
  :config
  (treemacs-icons-dired-mode))

(use-package treemacs-magit
  :after treemacs magit)

;; I'll leave treemacs, since other
;; packages like that..but here we have
;; neotree stuff
;; Requires all-the-icons for `icons'
;; (use-package neotree
;;   :bind
;;   ;; ("<f8>" .  neotree-toggle)

;;   :config
;;   ;; tips from:
;;   ;; https://www.emacswiki.org/emacs/NeoTree
;;   (setq neo-theme (if (display-graphic-p) 'icons 'arrow)
;; 	neo-smart-open t  ;; find current file and jump to node
;; 	;; the below changes root automatically on
;; 	;; projectile switch project
;; 	projectile-switch-project-action 'neotree-projectile-action))

;; Trying out dired-sidebar as a
;; treemacs/neotree replacement
;;; Requires vscode-icon for icons...
(use-package vscode-icon)

;; (use-package dired-sidebar
;;   :bind
;;   ("<f8>" . dired-sidebar-toggle-sidebar)
;;   :commands
;;   (dired-sidebar-toggle-sidebar)

;;   :config
;;   (setq dired-sidebar-theme 'vscode
;; 	dired-sidebar-use-term-integration t
;; 	dired-sidebar-use-custom-font t ))

;; Version Control / Source Code Repo
(use-package magit
  :bind
  ("C-c g" . magit-file-dispatch))

(use-package diff-hl
  :hook
  (magit-pre-refresh-hook . diff-hl-magit-pre-refresh)
  (magit-post-refresh-hook . diff-hl-magit-post-refresh)

  :init
  (global-diff-hl-mode 1))

;; Programming related stuff
;; Flycheck
(use-package flycheck
  :init
  (global-flycheck-mode)
  (diff-hl-flydiff-mode 1))

;; Tree Sitter
(use-package tree-sitter)
(use-package tree-sitter-langs)
(global-tree-sitter-mode)
;;(tree-sitter-hl-mode) ;; not ready for all langs yet

;; Parentheses stuff
(setq show-paren-delay 0)
(show-paren-mode t)
(set-face-background 'show-paren-match "#1e1e33")
(set-face-foreground 'show-paren-match nil)
(set-face-attribute 'show-paren-match nil
                    :weight 'bold
                    :underline nil
                    :overline nil
                    :slant 'normal)
(setq show-paren-style 'expression)

;; Highlight Sexp
;; https://www.emacswiki.org/emacs/HighlightSexp
;; Highlight the entire s-expression currently in
(straight-use-package '(highlight-sexp :host github
                      :repo "daimrod/highlight-sexp"
                      :branch "master"))
(setq hl-sexp-background-color "#1e1e33")
(add-hook 'lisp-mode-hook 'highlight-sexp-mode)
(add-hook 'emacs-lisp-mode-hook 'highlight-sexp-mode)

;; rainbow delimeters
(use-package rainbow-delimiters
  :hook
  (prog-mode . rainbow-delimiters-mode))

;; smartparens
(use-package smartparens
  :config
  (require 'smartparens-config)
  (smartparens-global-mode t)
  (define-key smartparens-mode-map (kbd "C-<right>") 'sp-forward-slurp-sexp)
  (define-key smartparens-mode-map (kbd "C-<left>") 'sp-forward-barf-sexp)
  (define-key smartparens-mode-map (kbd "C-M-<left>") 'sp-backward-slurp-sexp)
  (define-key smartparens-mode-map (kbd "C-M-<right>") 'sp-backward-barf-sexp))

;; YASnippet
;; LSP seems to need this?
;; this interferes with treemacs icons??!
;; and treemacs directory compaction
(use-package yasnippet
  :config
  (yas-global-mode 1)) ;; does this play nicely with treemacs lsp?


(use-package yasnippet-snippets)

;; Company
;; lots of stuff seems to need this, so...
(use-package company
  :hook
  ((prog-mode html-mode web-mode) . company-mode)

  :config
  (setq company-minimum-prefix-length 1
        company-idle-delay 0.4))

;; LSP Stuff
;; Need the following for Typescript/Angular
;; npm install -g @angular/language-service@next typescript @angular/language-server
(use-package lsp-mode
  :commands
  (lsp lsp-deferred)

  :hook
  ((html-mode web-mode json-mode
              js2-mode typescript-mode) . lsp-deferred)
  :init
  (setq lsp-keymap-prefix "C-c l"
        lsp-auto-configure t
        lsp-auto-guess-root t
        lsp-enable-completion-at-point t
        lsp-enable-indentation t
        lsp-lens-enable t
        lsp-enable-snippet t
        lsp-modeline-diagnostics-enable t)

  :config
  (lsp-enable-which-key-integration t)
  (lsp-headerline-breadcrumb-mode)
  (global-set-key (kbd "C-c l") lsp-command-map)
  (push 'emacs-lisp-mode lsp-disabled-clients))

(use-package lsp-ui
  :custom
  (lsp-ui-doc-position 'bottom))

;; lsp-treemacs: treemacs and yasnippets
;; don't behave for me. yasnippets interferes with
;; treemacs icons and directory compaction.
;; (use-package lsp-treemacs
;;   :after doom-themes
;;   :config
;;   (setq lsp-treemacs-sync-mode 1)
;;   (doom-themes-treemacs-config))  ;; this at least brings icons and stuff back, but ugly

(use-package consult-lsp
  :config
  (consult-lsp-marginalia-mode))

;; Note that company-lsp is no longer supported
;; (use-package company-lsp
;;   :config
;;   (setq company-lsp-cache-candidates 'auto
;; 	company-lsp-async t
;; 	company-lsp-enable-recompletion t)
;;   (push 'company-lsp company-backends))

;; Typescript
(use-package typescript-mode
  :hook
  (typescript-mode . lsp))

(use-package rjsx-mode
  :hook
  (rjsx-mode . lsp)
  (js2-mode . lsp)
  :mode
  ("\\.js\\'"
   "\\.jsx\\'")
  :config
  (setq js2-mode-show-parse-errors nil
        js2-mode-show-strict-warnings nil
        js2-basic-offset 2
        js-indent-level 2))

(use-package add-node-modules-path
  :hook
  (js2-mode . add-node-modules-path)
  (rjsx-mode . add-node-modules-path))

(use-package prettier-js
  :hook
  (js2-mode . prettier-js-mode)
  (rjsx-mode . prettier-js-mode)
  :custom
  (prettier-js-args '("--print-width" "100"
                      "--single-quote" "true"
                      "--trailing-comma" "all")))

;; Clojure
(use-package flycheck-clj-kondo)
(use-package flycheck-joker)

(use-package clojure-mode
  :hook
  (clojure-mode . lsp)
  (clojurescript-mode . lsp)
  (clojurec-mode . lsp)

  :config
  (require 'flycheck-clj-kondo)
  (require 'flycheck-joker)
  (dolist (checker '(clj-kondo-clj clj-kondo-cljs clj-kondo-cljc clj-kondo-edn))
    (setq flycheck-checkers (cons checker (delq checker flycheck-checkers))))
  (dolist (checkers '((clj-kondo-clj . clojure-joker)
                      (clj-kondo-cljs . clojurescript-joker)
                      (clj-kondo-cljc . clojure-joker)
                      (clj-kondo-edn . edn-joker)))
    (flycheck-add-next-checker (car checkers) (cons 'error (cdr checkers))))
  (setq clojure-align-forms-automatically t))

(use-package cider)

(use-package clj-deps-new
  :straight (clj-deps-new :type git
                          :host github
                          :repo "jpe90/emacs-clj-deps-new"))

;; (straight-use-package '(clj-deps-new :type git
;; 				     :host github
;; 				     :repo "jpe90/emacs-clj-deps-new"))

;; Guile Scheme
(use-package geiser-guile)

;; Web Mode
(use-package web-mode
  :config
  (setq web-mode-code-indent-offset 2
        web-mode-markup-indent-offset 2
        web-mode-attribute-indent-offset 2
        web-mode-css-indent-offset 2)
  (add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.[agj]sp\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.css\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.scss\\'" . web-mode))

  :hook
  (web-mode . lsp))

;; Emmet Mode
;; Seems to work well, does require C-j expansion
(use-package emmet-mode
  :hook
  ((sgml-mode css-mode) . emmet-mode)

  :config
  (setq emmet-move-cursor-between-quotes t))

;; Python Stuff
;; Function to auto set and activate the proper pyvenv
;; from: https://github.com/jorgenschaefer/pyvenv/issues/51#issuecomment-474785730
(defun swr/pyvenv-autoload ()
  "Automatically activates pyvenv version if .venv directory exists."
  (f-traverse-upwards
   (lambda (path)
     (let ((venv-path (f-expand ".venv" path)))
       (if (f-exists? venv-path)
           (progn
             (pyvenv-workon venv-path))
         t)))))
;; Will want the following installed in the virtual env:
;; python3-jedi black python3-autopep8 yapf3 python3-yapf
(use-package elpy
  :init
  (elpy-enable)
  :hook
  (python-mode . swr/pyvenv-autoload))

;; REST Client
(use-package restclient)

;; Org Mode
;; ....because why not
(use-package org
  :bind
  (("C-c o l" . org-store-link)
   ("C-c o a" . org-agenda)
   ("C-c o c" . org-capture))
  :init
  (require 'org-tempo)
  (org-babel-do-load-languages
   'org-babel-load-languages '((shell  . t)
                               (js  . t)
                               (emacs-lisp . t)
                               (clojure . t)
                               (python . t)))
  (setq org-babel-clojure-backend 'cider
        org-confirm-babel-evaluate nil
	org-directory "~/org"
	org-log-done 'time
	org-capture-templates
	'(;; My capture templates for org
	  ("b" "Bookmark" entry
	   (file+headline "~/org/notes.org" "Bookmarks")
	   "* %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n\n"
	   :empty-lines 1)
	  ;; More to come...
	  )))

;; Org Auto Tangle
(use-package org-auto-tangle
  :defer t
  :hook
  (org-mode . org-auto-tangle-mode)
  :init
  ;; Enable the following for default tangling
  ;; otherwise, use ~#+auto_tangle: t~
  ;; set to ~nil~ to disable.
  (setq org-auto-tangle-default t))

(define-skeleton org-header-skeleton
  "Header info for an Org file."
  "Title: ""#+TITLE: " str " \n"
  "#+AUTHOR: " user-full-name "\n"
  "#+EMAIL: " user-mail-address "\n"
  "#+DATE: " (format-time-string "%Y-%m-%d") "\n")

(global-set-key [C-S-f1] 'org-header-skeleton)

;; Org Roam
;; ..because, eh, why not
(setq swr/org-roam-directory (concat (getenv "HOME") "/Documents/org-roam/"))

;; This is a working hydra example for the
;; below keybinds of org-roam.
;; I'm not sure that it's worth it, though.
;; (defhydra swr-org-roam-hydra (global-map "C-c o")
;;   "Org Hydra"
;;   ("f" org-roam-node-find "Find Node" :column "Org Roam")
;;   ("g" org-roam-graph "Graph Node")
;;   ("r" org-roam-random "Random Node")
;;   ("c" org-roam-capture "Capture Node"))
;; Creates the following function to bind:
;; (swr-org-roam-hydra/body)

(use-package org-roam
  :after
  org

  :init
  (setq org-roam-v2-ack t) ;; dismiss the v2 upgrade buffer

  :custom
  (org-roam-directory (file-truename swr/org-roam-directory))
  (org-roam-completion-everywhere t)

  :config
  (org-roam-setup)
  (org-roam-db-autosync-mode)

  :bind
  (("C-c n f" . org-roam-node-find)
   ("C-c n g" . org-roam-graph)
   ("C-c n r" . org-roam-node-random)
   ("C-c n c" . org-roam-capture)
   (:map org-mode-map
         (("C-c n i" . org-roam-node-insert)
          ("C-M-i" . completion-at-point)
          ("C-c n o" . org-id-get-create)
          ("C-c n t" . org-roam-tag-add)
          ("C-c n a" . org-roam-alias-add)
          ("C-c n l" . org-roam-buffer-toggle)))))

;; Org Journal
(use-package org-journal
  :after org
  
  :init
  (setq org-journal-prefix-key "C-c j")

  :config
  (with-eval-after-load 'org-capture 
    (setq org-journal-dir "~/org/journal/"
	  org-journal-date-format "%A, %d %B %Y"
	  org-journal-file-format "%Y-%m-%d.org"
	  org-journal-file-header "#+TITLE: Daily Journal\n#+STARTUP: showeverything")
    ;; Capture template addition
    (defun org-journal-find-location ()
      ;; from https://github.com/bastibe/org-journal#journal-capture-template
      ;; Open today's journal, but specify a non-nil prefix argument in order
      ;; to inhibit inserting the heading; org-capture will insert the heading.
      (org-journal-new-entry t)
      (unless (eq org-journal-file-type 'daily)
	(org-narrow-to-subtree))
      (goto-char (point-max)))
    
    (add-to-list 'org-capture-templates
		 '("j" "Journal entry" plain
		   (function org-journal-find-location)
		   "** %(format-time-string org-journal-time-format)%^{Title}\n%i\n%?"
		   :jump-to-captured nil
		   :immediate-finish nil))))

;; Polymode for ORG
(use-package polymode)

;; Polymode - Markdown
(use-package poly-markdown)

;; Polymode - R
;; This needs ESS installed as well
(use-package ess
 :init
 (require 'ess-r-mode))

(use-package poly-R
  :config
  ;; The following come from:
  ;; https://plantarum.ca/2021/10/03/emacs-tutorial-rmarkdown/
  ;; Enable Github Flavored markdown for Rmd files
  (add-to-list 'auto-mode-alist '("\\.[rR]md\\'" . poly-gfm+r-mode))
  ;; Have gfm-mode automatically insert braces for code blocks
  (setq markdown-code-block-braces t))

;; Start the emacs server daemon, because
;; of org-protocal usage
;; (server-start)
;; eventually, maybe, go with a proper daemon

;; org-protocol
;; also need: https://gist.github.com/detrout/d27ad655bfb3b09007fa2683f213d4cb
;;
;; ~/.local/share/applications/org-protocol.desktop
;; --------------------
;; [Desktop Entry]
;; Version=1.0
;; Name=org-protocol helper
;; Comment=helper to allow GNOME to open org-protocol: pseudo-urls
;; TryExec=/usr/bin/emacsclient
;; Exec=/usr/bin/emacsclient %u
;; NoDisplay=true
;; Icon=emacs24
;; Terminal=false
;; Type=Application

;; ~/.config/mimeapps.list:
;; add:
;; [Added Associations]
;; x-scheme-handler/org-protocol=org-protocol.desktop;

;; (require 'org-protocol)

;; ox-hugo for website building
;; https://www.kengrimes.com/ox-hugo-tutorial/
(use-package ox-hugo
  :config
  (with-eval-after-load 'org-capture
    (defun org-hugo-new-subtree-post-capture-template ()
      "Returns `org-capture' template string for new Hugo post."
      (let* ((title (read-from-minibuffer "Post Title: "))
	     (fname (org-hugo-slug title)))
	(mapconcat #'identity
		   `(,(concat "* TODO " title)
		     ":PROPERTIES:"
		     ,(concat ":EXPORT_FILE_NAME: " fname)
		     ":END:"
		     "%?\n")
		   "\n")))
    (add-to-list 'org-capture-templates
		 '("h" "Hugo post" entry
		   (file+olp "all-posts.org" "Blog Posts")
		   (function org-hugo-new-subtree-post-capture-template)))))

;; Load the custom.el file should it exist
(when (file-exists-p custom-file)
  (load custom-file))
