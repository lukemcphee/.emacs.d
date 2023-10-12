;; You will most likely need to adjust this font size for your system!
(defvar runemacs/default-font-size 180)

(setq inhibit-startup-message t)

;;(tool-bar-mode -1)          ; Disable the toolbar
;;(tooltip-mode -1)           ; Disable tooltips

(menu-bar-mode -1)            ; Disable the menu bar

;; Set up the visible bell
(setq visible-bell t)

;; Just install fira code for this to work

;;(set-face-attribute 'default nil :font "Fira Code Retina" :height runemacs/default-font-size)

;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)


;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
 (package-refresh-contents))

;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
   (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(column-number-mode)
(global-display-line-numbers-mode t)
(set-face-attribute 'default nil :height 132)

;; required for gpg, auth key should be appropriately encrypted
;; https://practical.li/spacemacs/source-control/forge-configuration.html 
(setq auth-sources '("~/.authinfo.gpg"))
(require 'epa-file)
(setq epa-file-select-keys nil)
(setq epa-file-encrypt-to '("luke.mcphee@currenthealth.com"))
(setq password-cache-expiry (* 60 15))
;; Fix EasyPG error.
;; From https://colinxy.github.io/software-installation/2016/09/24/emacs25-easypg-issue.html.
(defvar epa-pinentry-mode)
(setq epa-pinentry-mode 'loopback)

;; lsp modes

;; this is required to pull path correctly for things like node
(use-package exec-path-from-shell)
(when (memq window-system '(mac ns x))
  (exec-path-from-shell-initialize))



;; Your mac specific setting
;; default below from https://github.com/neppramod/java_emacs/blob/master/mac.el
;;(setenv "JAVA_HOME"  "path_to_java_folder/Contents/Home/")
;;(setq lsp-java-java-path "path_to_java_folder/Contents/Home/bin/java")
(setenv "JAVA_HOME"  "/Users/luke.mcphee/.jenv/versions/17.0")
(setq lsp-java-java-path "/Library/Java/JavaVirtualMachines/openjdk-17.jdk/Contents/Home/bin/java")


(use-package lsp-mode
  ;; Optional - enable lsp-mode automatically in scala files
  :ensure t
  :hook (haskell-mode . lsp)
  :hook (scala-mode . lsp)
  :hook (
   (lsp-mode . lsp-enable-which-key-integration)
   (java-mode . #'lsp-deferred)
   )
  :init (setq 
lsp-keymap-prefix "C-c l"              ; this is for which-key integration documentation, need to use lsp-mode-map
lsp-enable-file-watchers nil
read-process-output-max (* 1024 1024)  ; 1 mb
lsp-completion-provider :capf
lsp-idle-delay 0.500
)
  :config
  (setq lsp-prefer-flymake nil)
  (setq lsp-intelephense-multi-root nil) ; don't scan unnecessary projects
  )
;; dunno why svg is used in scala-mode, but it is until mac for os runs emacs 29.x
(add-to-list 'image-types 'svg)
(use-package lsp-java 
:ensure t
:config (add-hook 'java-mode-hook 'lsp))

(use-package lsp-treemacs
  :after (lsp-mode treemacs)
  :ensure t
  :commands lsp-treemacs-errors-list
  :bind (:map lsp-mode-map
         ("M-9" . lsp-treemacs-errors-list)))

(use-package treemacs
  :ensure t
  :commands (treemacs)
  :after (lsp-mode))

(use-package groovy-mode
  :hook
  (kotlin-mode . lsp))

(use-package kotlin-mode
  :hook
  (kotlin-mode . lsp))

;; Add company-lsp backend for metals
;; from https://github.com/scalameta/metals/pull/2672/files
(use-package company
   :hook (scala-mode . company-mode)
   :config
   (setq lsp-completion-provider :capf))
(use-package lsp-metals)


(use-package lsp-ui
:ensure t
:after (lsp-mode)
:commands lsp-ui-mode ;; this is necessary to get info about compilation
:bind (:map lsp-ui-mode-map
         ([remap xref-find-definitions] . lsp-ui-peek-find-definitions)
         ([remap xref-find-references] . lsp-ui-peek-find-references))
:init (setq lsp-ui-doc-delay 1.5
      lsp-ui-doc-position 'bottom
 lsp-ui-doc-max-width 100
))

;; https://github.com/neppramod/java_emacs/blob/master/emacs-configuration.org
(use-package helm-lsp
:ensure t
:after (lsp-mode)
:commands (helm-lsp-workspace-symbol)
:init (define-key lsp-mode-map [remap xref-find-apropos] #'helm-lsp-workspace-symbol))

;; haskellj
;; (use-package haskell-mode)
;; (defun my-haskell-hook ()
;;   (progn
;;     (interactive-haskell-mode)
;;     (haskell-doc-mode)
;;     (haskell-indentation-mode)
;; ))
;; (add-hook 'haskell-mode-hook 'my-haskell-hook)
;; config from https://abailly.github.io/posts/a-modern-haskell-env.html
(use-package lsp-haskell
  :ensure t
  :config
 (setq lsp-haskell-server-path "haskell-language-server-wrapper")
 ;; gives a little preview on hover, useful for inspecting types. set to nil to remove. 
 ;; full list of options here https://emacs-lsp.github.io/lsp-mode/tutorials/how-to-turn-off/
 (setq lsp-ui-sideline-show-hover t)
 (setq lsp-haskell-server-args ())
   ;; Comment/uncomment this line to see interactions between lsp client/server.
  (setq lsp-log-io t))
(use-package yasnippet
  :ensure t
  :config
  (setq yas-snippet-dirs '("~/.emacs.d/snippets"))
  (yas-global-mode)
  )
(use-package yasnippet-snippets :ensure t)

;; ocaml start
;; Major mode for OCaml programming
(use-package tuareg
  :ensure t
  :mode (("\\.ocamlinit\\'" . tuareg-mode)))

;; Major mode for editing Dune project files
(use-package dune
  :ensure t)

;; Merlin provides advanced IDE features
(use-package merlin
  :ensure t
  :config
  (add-hook 'tuareg-mode-hook #'merlin-mode)
  (add-hook 'merlin-mode-hook #'company-mode)
  ;; we're using flycheck instead
  (setq merlin-error-after-save nil))

(use-package merlin-eldoc
  :ensure t
  :hook ((tuareg-mode) . merlin-eldoc-setup))

;; This uses Merlin internally
(use-package flycheck-ocaml
  :ensure t
  :config
  (flycheck-ocaml-setup))
;; utop configuration
(use-package utop
  :ensure t
  :config
  (add-hook 'tuareg-mode-hook #'utop-minor-mode))
;; ocaml end

;; typescript - https://willschenk.com/articles/2021/setting_up_emacs_for_typescript_development/
(use-package tide :ensure t)
(use-package company :ensure t)
(use-package typescript-mode :ensure t)
(use-package flycheck
  :ensure t
  :init
  (global-flycheck-mode t))
(defun setup-tide-mode ()
  (interactive)
  (tide-setup)
  (flycheck-mode +1)
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (eldoc-mode +1)
  (tide-hl-identifier-mode +1)
  ;; company is an optional dependency. You have to
  ;; install it separately via package-install
  ;; `M-x package-install [ret] company`
  (company-mode +1))
;; aligns annotation to the right hand side
(setq company-tooltip-align-annotations t)
;; formats the buffer before saving
(add-hook 'before-save-hook 'tide-format-before-save)
(add-hook 'typescript-mode-hook #'setup-tide-mode)
;; enable typescript - tslint checker


;; python stuff
(use-package elpy
  :ensure t
  :defer t
  :init
  (advice-add 'python-mode :before 'elpy-enable))


;; pretty print stuff
;; http://www.modernemacs.com/post/prettify-mode/
(use-package pretty-mode)
(global-pretty-mode t)
(pretty-deactivate-groups
 '(:equality :ordering :ordering-double :ordering-triple
             :arrows :arrows-twoheaded :punctuation
             :logic :sets))
(pretty-activate-groups
 '(:sub-and-superscripts :greek :arithmetic-nary))

(global-prettify-symbols-mode 1)
(add-hook
 'python-mode-hook
 (lambda ()
   (mapc (lambda (pair) (push pair prettify-symbols-alist))
         '(;; Syntax
           ("def" .      #x2131)
;;           ("not" .      #x2757)
           ("in" .       #x2208)
           ("not in" .   #x2209)
           ("return" .   #x27fc)
           ("yield" .    #x27fb)
;;           ("for" .      #x2200)
           ;; Base Types
;;           ("int" .      #x2124)
;;           ("float" .    #x211d)
;;           ("str" .      #x1d54a)
           ("True" .     #x1d54b)
           ("False" .    #x1d53d)
           ;; Mypy
;;           ("Dict" .     #x1d507)
;;           ("List" .     #x2112)
           ("Set" .      #x2126)
           ("Iterable" . #x1d50a)
           ("Union" .    #x22c3)))))

;; pretty print stuff end 
;; scala and ammonite stuff
;;https://sideshowcoder.com/2021/12/30/new-scala-3-syntax-in-emacs/
(defun is-scala3-project ()
  "Check if the current project is using scala3.

Loads the build.sbt file for the project and serach for the scalaVersion."
  (projectile-with-default-dir (projectile-project-root)
    (when (file-exists-p "build.sbt")
      (with-temp-buffer
        (insert-file-contents "build.sbt")
        (search-forward "scalaVersion := \"3" nil t)))))
(defun with-disable-for-scala3 (orig-scala-mode-map:add-self-insert-hooks &rest arguments)
    "When using scala3 skip adding indention hooks."
    (unless (is-scala3-project)
      (apply orig-scala-mode-map:add-self-insert-hooks arguments)))

(advice-add #'scala-mode-map:add-self-insert-hooks :around #'with-disable-for-scala3)
(defun disable-scala-indent ()
  "In scala 3 indent line does not work as expected due to whitespace grammar."
  (when (is-scala3-project)
    (setq indent-line-function 'indent-relative-maybe)))

(add-hook 'scala-mode-hook #'disable-scala-indent)
(use-package scala-mode
  :mode "\\.s\\(cala\\|bt\\)$"
  :config
  ;;(load-file "~/.emacs.d/lisp/ob-scala.el")
  )
;; you'll need to install `amm` obviously
;; (use-package ob-ammonite
;;   :defer 1
;;   :config
;;   (use-package ammonite-term-repl)
;;   (setq ammonite-term-repl-auto-detect-predef-file nil)
;;   (setq ammonite-term-repl-program-args '("--no-remote-logging" "--no-default-predef" "--no-home-predef"))
;;   (defun my/substitute-sbt-deps-with-ammonite ()
;;     "Substitute sbt-style dependencies with ammonite ones."
;;     (interactive)
;;     (apply 'narrow-to-region (if (region-active-p) (my/cons-cell-to-list (region-bounds)) `(,(point-min) ,(point-max))))
;;     (goto-char (point-min))
;;     (let ((regex "\"\\(.+?\\)\"[ ]+%\\{1,2\\}[ ]+\"\\(.+?\\)\"[ ]+%\\{1,2\\}[ ]+\"\\(.+?\\)\"")
;;           (res))
;;       (while (re-search-forward regex nil t)
;;         (let* ((e (point))
;;                (b (search-backward "\"" nil nil 6))
;;                (s (buffer-substring-no-properties b e))
;;                (s-without-percent (apply 'concat (split-string s "%")))
;;                (s-without-quotes (remove-if (lambda (x) (eq x ?" ;"
;;                                                             ))
;;                                             s-without-percent))
;;                (s-as-list (split-string s-without-quotes)))
;;                     (delete-region b e)
;;           (goto-char b)
;;           (insert (format "import $ivy.`%s::%s:%s`" (first s-as-list) (second s-as-list) (third s-as-list)))
;;           )
;;         )
;;       res)
;;     (widen)))

;; the t parameter apends to the hook, instead of prepending
;; this means it'd be run after other hooks that might fiddle
;; start the initial frame maximized
(add-to-list 'initial-frame-alist '(fullscreen . maximized))
;; start every frame maximized
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; org-present start
;; required for images scaling properly, this is a hack. 
(use-package org-present)
(setq org-image-actual-width (list 550))
;; Install visual-fill-column
;; note: you could probably use olivetti mode for this for a more lightweight solution, but the images aren't working yet.
;; probably a good thing to fix at some point as they dont' play nicely atm and word wrapping is horrible
(unless (package-installed-p 'visual-fill-column)
  (package-install 'visual-fill-column))
;; Configure fill width
(setq visual-fill-column-center-text t)
(defun my/org-present-start ()

  ;; Tweak font sizes
  (setq-local face-remapping-alist '(
                                     (header-line (:height 4.0) variable-pitch)
                                     (org-document-title (:height 1.75) org-document-title)
                                     (org-code (:height 1.55) org-code)
    )
     )

  
  ;; Set a blank header line string to create blank space at the top
  (setq header-line-format " ")

  ;; Display inline images automatically
  (org-display-inline-images)

  ;; Center the presentation and wrap lines
  (visual-fill-column-mode 1)
  (visual-line-mode 1)
  ;; change margins so long lines fit
  (setq
   ;; adjust right hand margin so it fits longer lines
   visual-fill-column-extra-text-width '(10 . 30)
   ;; pad  wraps to cover the indent from previous bullet
   wrap-prefix "    ")
  ;; ;; this works, but it also decreases left margin :(
  ;;(setq visual-fill-column-width 100)
  )
(defun my/org-present-end ()
  ;; Reset font customizations
  (setq-local face-remapping-alist '((default variable-pitch default)))

  ;; Clear the header line string so that it isn't displayed
  (setq header-line-format nil)

  ;; Clear the header line string so that it isn't displayed
  (setq header-line-format nil)

  ;; Stop displaying inline images
  (org-remove-inline-images)

  ;; Stop centering the document
  (visual-fill-column-mode 0)
  (visual-line-mode 0)
  )

(defun my/org-present-prepare-slide (buffer-name heading)
  ;; Show only top-level headlines
  ;;(org-overview)

  ;; Unfold the current entry
  (org-show-entry)

  ;; Show only direct subheadings of the slide but don't expand them
  (org-show-children)
  )


;; Register hooks with org-present
(add-hook 'org-present-after-navigate-functions 'my/org-present-prepare-slide)
(add-hook 'org-present-mode-hook 'my/org-present-start)
(add-hook 'org-present-mode-quit-hook 'my/org-present-end)

(setq org-hide-emphasis-markers t)
;; org-present end

;; Disable line numbers for some modes
(dolist (mode '(org-mode-hook
                term-mode-hook
                shell-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))
;; when line numbers is enabled use relative
(global-display-line-numbers-mode 1)
(setq display-line-numbers-type 'relative)

(use-package command-log-mode)

;; NOTE: The first time you load your configuration on a new machine, you'll
;; need to run the following command interactively so that mode line icons
;; display correctly:
;;
;; M-x all-the-icons-install-fonts

(use-package all-the-icons)

;; extra packages
;; rg for ripgrip
(use-package rg)
(rg-enable-default-bindings)

;; custom configs 
;; call with `recentf-open-files`
(recentf-mode 1)
;;(scroll-bar-mode -1) 

;; Remember and restore the last cursor location of opened files
(save-place-mode 1)

;; terraform
(use-package terraform-mode)

;; term stuff 
(use-package vterm
  :commands vterm
  :config
  ;;(setq term-prompt-regexp "^[^#$%>\n]*[#$%>] *")  ;; Set this to match your custom shell prompt
  ;;(setq vterm-shell "zsh")                       ;; Set this to customize the shell to launch
  (setq vterm-max-scrollback 10000))

;;(use-package doom-modeline
;;  :init (doom-modeline-mode 1)
;;  :custom ((doom-modeline-height 15)))
;;https://github.com/neppramod/java_emacs/blob/master/emacs-configuration.org
(use-package doom-themes
:ensure t 
:init 
(load-theme 'doom-palenight t))

(use-package heaven-and-hell
  :ensure t
  :init
  (setq heaven-and-hell-themes
        '((light . doom-acario-light)
          (dark . doom-palenight)))
  (setq heaven-and-hell-theme-type 'dark)
  :hook (after-init . heaven-and-hell-init-hook)
  :bind (("C-c <f6>" . heaven-and-hell-load-default-theme)
         ("<f6>" . heaven-and-hell-toggle-theme)))

(use-package protobuf-mode :ensure t)

(defun my/ansi-colorize-buffer ()
(let ((buffer-read-only nil))
(ansi-color-apply-on-region (point-min) (point-max))))

(use-package ansi-color
:ensure t
:config
(add-hook 'compilation-filter-hook 'my/ansi-colorize-buffer))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 1))

;;(use-package ivy
;;  :diminish
;;  :bind (
;; ("C-s" . swiper)
;;         :map ivy-minibuffer-map
;;         ("TAB" . ivy-alt-done)
;;         ("C-l" . ivy-alt-done)
;;         ("C-j" . ivy-next-line)
;;         ("C-k" . ivy-previous-line)
;;         :map ivy-switch-buffer-map
;;         ("C-k" . ivy-previous-line)
;;         ("C-l" . ivy-done)
;;         ("C-d" . ivy-switch-buffer-kill)
;;         :map ivy-reverse-i-search-map
;;         ("C-k" . ivy-previous-line)
;;         ("C-d" . ivy-reverse-i-search-kill))
;;  :config
;;  (ivy-mode 1))
;;(use-package lsp-ivy
;;  :commands lsp-ivy-workspace-symbol)
;;(use-package ivy-rich
;;  :init
;;  (ivy-rich-mode 1))
;;(use-package prescient)
;;(use-package ivy-prescient
;;  :after counsel
;;  :config
;;  (ivy-prescient-mode 1))

;;(use-package corfu-prescient)
;;(use-package selectrum-prescient)
;;(use-package vertico-prescient)

;;(use-package counsel
;;  :bind (("M-x" . counsel-M-x)
;;         ("C-x b" . counsel-ibuffer)
;;         ("C-x C-f" . counsel-find-file)
;;         :map minibuffer-local-map
;;         ("C-r" . 'counsel-minibuffer-history)))

(use-package helm
:ensure t
:init 
(helm-mode 1)
(progn (setq helm-buffers-fuzzy-matching t))
:bind
(("C-c h" . helm-command-prefix))
(("M-x" . helm-M-x))
(("C-x C-f" . helm-find-files))
(("C-x b" . helm-buffers-list))
(("C-c b" . helm-bookmarks))
(("C-c f" . helm-recentf))   ;; Add new key to recentf
(("C-c g" . helm-grep-do-git-grep)))  ;; Search using grep in a git project

(use-package helm-descbinds
:ensure t
:bind ("C-h b" . helm-descbinds)

)
(use-package helm-swoop 
:ensure t
:bind ("C-s" . helm-swoop)
:init
(bind-key "M-m" 'helm-swoop-from-isearch isearch-mode-map)
;; If you prefer fuzzy matching
(setq helm-swoop-use-fuzzy-match t)
;; Save buffer when helm-multi-swoop-edit complete
(setq helm-multi-swoop-edit-save t)
;; If this value is t, split window inside the current window
(setq helm-swoop-split-with-multiple-windows nil)
;; Split direction. 'split-window-vertically or 'split-window-horizontally
(setq helm-swoop-split-direction 'split-window-vertically)
;; If nil, you can slightly boost invoke speed in exchange for text color
(setq helm-swoop-speed-or-color nil)
;; ;; Go to the opposite side of line from the end or beginning of line
(setq helm-swoop-move-to-line-cycle t)
)

(use-package company-prescient
  :after company
  :config
  (company-prescient-mode 1))

(use-package helpful
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

;; presceint is used for sorting ivy output, comment in as you add stuff
;; https://github.com/daviwil/emacs-from-scratch/blob/805bba054513e3a2a2aa48648d7bebb1536ea4bc/show-notes/Emacs-Tips-Prescient.org

(use-package general
  :config
  (general-create-definer rune/leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC")

  (rune/leader-keys
    "t"  '(:ignore t :which-key "toggles")
    "tt" '(counsel-load-theme :which-key "choose theme")))

;; custom key bindings
(global-set-key "\C-x\C-f" 'projectile-find-file)
(global-set-key "\C-x\ \C-r" 'counsel-recentf)
(global-set-key "\C-x\ \C-e" 'counsel-rg)
(defun split-and-follow-horizontally ()
  (interactive)
  (split-window-below)
  (balance-windows)
  (other-window 1))
(global-set-key (kbd "C-x 2") 'split-and-follow-horizontally)

(defun split-and-follow-vertically ()
  (interactive)
  (split-window-right)
  (balance-windows)
  (other-window 1))
(global-set-key (kbd "C-x 3") 'split-and-follow-vertically)

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  ;; custom variables
  (define-key evil-insert-state-map (kbd "C-c C-c") 'evil-normal-state)
  (define-key evil-normal-state-map (kbd "C-c C-c") 'evil-normal-state)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(evil-define-minor-mode-key 'normal lsp-mode (kbd "SPC l") lsp-command-map)


(use-package hydra)


(defhydra hydra-text-scale (:timeout 4)
  "scale text"
  ("j" text-scale-increase "in")
  ("k" text-scale-decrease "out")
  ("f" nil "finished" :exit t))

(rune/leader-keys
  "ts" '(hydra-text-scale/body :which-key "scale text"))

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  ;; NOTE: Set this to the folder where you keep your Git repos!
  (when (file-directory-p "~/code")
    (setq projectile-project-search-path '("~/code")))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package counsel-projectile
  :config (counsel-projectile-mode))

(use-package magit
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; NOTE: Make sure to configure a GitHub token before using this package!
;; - https://magit.vc/manual/forge/Token-Creation.html#Token-Creation
;; - https://magit.vc/manual/ghub/Getting-Started.html#Getting-Started
(use-package forge)
;; Move customization variables to a separate file and load it
(setq custom-file (locate-user-emacs-file "custom-vars.el"))
(load custom-file 'noerror 'nomessage)
;; stops big horrible yellow banner on WARN's
(setq visible-bell nil)
;; Revert buffers when the underlying file has changed
(global-auto-revert-mode 1)
;; Revert Dired and other buffers
(setq global-auto-revert-non-file-buffers t)
