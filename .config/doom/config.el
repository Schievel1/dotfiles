(setq user-full-name "Pascal Jäger"
      user-mail-address "pascal.jaeger@leimstift.de")

(setq doom-font (font-spec :family "Victor Mono Semibold" :size 14)
      doom-variable-pitch-font (font-spec :family "Victor Mono Semibold" :size 14))

;; Make comments use text non monospace fond
;; (set-face-attribute 'font-lock-comment-face nil
		    ;; :family "Sans")

(setq doom-theme 'doom-tokyo-night)
(global-display-line-numbers-mode)
(setq display-line-numbers-type 'relative)
(doom/set-frame-opacity 95) ;; now more worky in emacs 29
(set-frame-parameter nil 'alpha-background 95) ; For current frame
(add-to-list 'default-frame-alist '(alpha-background . 95)) ; For all new frames henceforth
(setq evil-move-cursor-back nil)
(setq doom-themes-treemacs-theme "doom-colors")

(setq centaur-tabs-style "wave")
(setq centaur-tabs-set-bar 'under)
;; Note: If you're not using Spacmeacs, in order for the underline to display
;; correctly you must add the following line:
(setq x-underline-at-descent-line t)
(setq centaur-tabs-height 32)

(evil-define-key 'normal centaur-tabs-mode-map (kbd "g h")  'centaur-tabs-forward-group
  (kbd "g H")    'centaur-tabs-backward-group)

;; (require 'zone)
;; (zone-when-idle 600)

(display-time-mode 1)                             ; Enable time in the mode-line
(custom-set-faces!
  '(doom-modeline-buffer-modified :foreground "orange"))

(setq doom-modeline-major-mode-icon t)

(defun doom-modeline-conditional-buffer-encoding ()
  "We expect the encoding to be LF UTF-8, so only show the modeline when this is not the case"
  (setq-local doom-modeline-buffer-encoding
	      (unless (and (memq (plist-get (coding-system-plist buffer-file-coding-system) :category)
				 '(coding-category-undecided coding-category-utf-8))
			   (not (memq (coding-system-eol-type buffer-file-coding-system) '(1 2))))
		t)))

(add-hook 'after-change-major-mode-hook #'doom-modeline-conditional-buffer-encoding)

(nyan-mode)
(setq nyan-animate-nyancat t
      nyan-wavy-trail nil)

(setq org-directory (directory-files-recursively "~/org/" "\\.org$"))
(setq org-roam-directory "~/Nextcloud/org/roam")
(setq org-roam-dailies-directory "~/Nextcloud/org/roam/roam-dailies")

(require 'org-roam-dailies)
(setq org-roam-dailies-capture-templates
      '(("d" "default" entry "* %?"
	 :if-new (file+head "%<%Y-%m-%d>.org" "#+title: %<%Y-%m-%d>\n"))))
(setq org-roam-completion-everywhere t)

(defun org-roam-node-insert-immediate (arg &rest args)
  (interactive "P")
  (let ((args (cons arg args))
	(org-roam-capture-templates (list (append (car org-roam-capture-templates)
						  '(:immediate-finish t)))))
    (apply #'org-roam-node-insert args)))

(map! :leader
      (:prefix-map ("n" . "notes")
	           (:prefix-map ("r" . "roam")
		    :desc "Insert immediate"           "I" #'org-roam-node-insert-immediate
		    :desc "Enable Org-Roam-UI"         "u" #'org-roam-ui-mode
		    :desc "Open random node"           "a" #'org-roam-node-random
		    :desc "Find node"                  "f" #'org-roam-node-find
		    :desc "Find ref"                   "F" #'org-roam-ref-find
		    :desc "Show graph"                 "g" #'org-roam-graph
		    :desc "Insert node"                "i" #'org-roam-node-insert
		    :desc "Capture to node"            "n" #'org-roam-capture
		    :desc "Toggle roam buffer"         "r" #'org-roam-buffer-toggle
		    :desc "Launch roam buffer"         "R" #'org-roam-buffer-display-dedicated
		    :desc "Sync database"              "s" #'org-roam-db-sync
		    (:prefix ("d" . "by date")
		     :desc "Goto previous note"        "b" #'org-roam-dailies-goto-previous-note
		     :desc "Goto date"                 "d" #'org-roam-dailies-goto-date
		     :desc "Capture date"              "D" #'org-roam-dailies-capture-date
		     :desc "Goto next note"            "f" #'org-roam-dailies-goto-next-note
		     :desc "Goto tomorrow"             "m" #'org-roam-dailies-goto-tomorrow
		     :desc "Capture tomorrow"          "M" #'org-roam-dailies-capture-tomorrow
		     :desc "Capture today"             "n" #'org-roam-dailies-capture-today
		     :desc "Goto today"                "t" #'org-roam-dailies-goto-today
		     :desc "Capture today"             "T" #'org-roam-dailies-capture-today
		     :desc "Goto yesterday"            "y" #'org-roam-dailies-goto-yesterday
		     :desc "Capture yesterday"         "Y" #'org-roam-dailies-capture-yesterday
		     :desc "Find directory"            "-" #'org-roam-dailies-find-directory))))

(use-package! websocket
  :after org-roam)

(use-package! org-roam-ui
  :after org-roam
  :config
  (setq org-roam-ui-sync-theme t
	org-roam-ui-follow t
	org-roam-ui-update-on-save t
	org-roam-ui-open-on-start t))

(with-eval-after-load 'org
  (require 'edraw-org)
  (edraw-org-setup-default))

(require 'org-side-tree)
(map!
      :leader
      :prefix "o"
      :desc "Org side tree"
      "s" #'org-side-tree)

(defun boxes-headline ()
  (interactive)
  (shell-command-on-region (region-beginning) (region-end) "boxes -d headline" nil 1 nil))

(defun boxes-remove-headline ()
  (interactive)
  (shell-command-on-region (region-beginning) (region-end) "boxes -r -d headline" nil 1 nil))

(defun pascal/evil-safe-paste-after ()
  "Paste the evil register but don't overwrite the register"
  (interactive)
  (setq paste-backup (evil-get-register ?+))
  (set-text-properties 0 (length paste-backup) nil paste-backup)
  (evil-paste-after 1)
  (evil-set-register ?+ paste-backup))

(defun pascal/evil-safe-paste-before ()
  "Paste the evil register but don't overwrite the register"
  (interactive)
  (setq paste-backup (evil-get-register ?+))
  (set-text-properties 0 (length paste-backup) nil paste-backup)
  (evil-paste-before 1)
  (evil-set-register ?+ paste-backup))

(map! :leader
      :desc "evil-safe-paste-after" "v" #'pascal/evil-safe-paste-after
      :desc "evil-safe-paste-after" "V" #'pascal/evil-safe-paste-before)

(defun evil-scroll-up-and-center ()
  (interactive)
  (evil-scroll-up 0)
  (evil-scroll-line-to-center nil))
(defun evil-scroll-down-and-center ()
  (interactive)
  (evil-scroll-down 0)
  (evil-scroll-line-to-center nil))
(map! :map evil-motion-state-map
      "C-u" nil
      "C-d" nil)
(map! "C-u" #'evil-scroll-up-and-center)
(map! "C-d" #'evil-scroll-down-and-center)

(map! :leader
      :desc "join-line" "j" #'join-line)

(elcord-mode)
(setq elcord-editor-icon "emacs_icon")

;; Work around a bug where esup tries to step into the byte-compiled
;; version of `cl-lib', and fails horribly.
(setq esup-depth 0)

(require 'yasnippet)
(yas-global-mode 1)
;; ox man is used to generate man pages from org mode files
(require 'ox-man)
(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)

(use-package! tree-sitter
  :config
  (require 'tree-sitter-langs)
  (global-tree-sitter-mode)
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))

(setq company-box-icons-alist 'company-box-icons-images)
(setq company-tooltip-maximum-width 70)

;; Emacs avy
(setq avy-keys '(?a ?o ?e ?u ?i ?d ?h ?t ?n ?s))
(map! :after evil-easymotion
      :map evilem-map
      "l" #'avy-goto-line)

(setq vterm-always-compile-module t)

(map! :leader
      :desc "evil-window-left" "w <left>" #'evil-window-left)
(map! :leader
      :desc "evil-window-right" "w <right>" #'evil-window-right)
(map! :leader
      :desc "evil-window-down" "w <down>" #'evil-window-down)
(map! :leader
      :desc "evil-window-up" "w <up>" #'evil-window-up)


;; Ask what to open for a new split
(setq evil-vsplit-window-right t
      evil-split-window-below t)
(defadvice! prompt-for-buffer (&rest _)
  :after '(evil-window-split evil-window-vsplit)
  (consult-buffer))

(custom-set-faces!
  '(aw-leading-char-face
    :foreground "white" :background "red"
    :weight bold :height 2.5 :box (:line-width 10 :color "red")))
(setq aw-keys '(?a ?o ?e ?u ?i ?d ?h ?t ?n ?s))
(map! :leader "d" #'ace-window)

(use-package! hydra
  :defer
  :config
  (defhydra hydra/evil-window-resize (:color red)
    "Resize window"
    ("h" evil-window-increase-width "increase width")
    ("t" evil-window-increase-height "increase height")
    ("n" evil-window-decrease-height "decrease height")
    ("s" evil-window-decrease-width "decrease width")
    ("q" nil "quit")))

(map! :leader
      :prefix ("w" . "window")
      :n "r" #'hydra/evil-window-resize/body)
;; Add keymap for Command-/ to toggle a comment line and also move the cursor down one line
(map! :desc "Toggle comment line and move down one line"
      :n "l" #'my/comment-line-and-move-down
      :desc "Toggle comment line and move down one line"
      :v "l" #'comment-line)

;; You can use this hydra menu that have all the commands
(map! :n "C-SPC" 'harpoon-quick-menu-hydra)
(map! :leader "r" 'harpoon-quick-menu-hydra)
(map! :n "C-s" 'harpoon-add-file)

;; And the vanilla commands
(map! :leader "k c" 'harpoon-clear)
(map! :leader "k f" 'harpoon-toggle-file)
(map! :leader "1" 'harpoon-go-to-1)
(map! :leader "2" 'harpoon-go-to-2)
(map! :leader "3" 'harpoon-go-to-3)
(map! :leader "4" 'harpoon-go-to-4)
(map! :leader "5" 'harpoon-go-to-5)
(map! :leader "6" 'harpoon-go-to-6)
(map! :leader "7" 'harpoon-go-to-7)
(map! :leader "8" 'harpoon-go-to-8)
(map! :leader "9" 'harpoon-go-to-9)

(use-package! dirvish
  :defer nil
  :config
  (setq delete-by-moving-to-trash t)
  (setq dired-mouse-drag-files t)                   ; added in Emacs 29
  (setq mouse-drag-and-drop-region-cross-program t) ; added in Emacs 29
  (setq mouse-1-click-follows-link t)
  (define-key dirvish-mode-map (kbd "<mouse-1>") 'dired-find-file)
  (define-key dirvish-mode-map (kbd "<mouse-2>") 'dired-mouse-find-file-other-window)
  (define-key dirvish-mode-map (kbd "<mouse-8>") 'dired-up-directory)
  (define-key dirvish-mode-map (kbd "<mouse-9>") 'dired-find-file)
  (map! :map dirvish-mode-map
	:n  "?"   #'dirvish-dispatch
        ;;        :n  "q"   #'dirvish-quit
	:n  "h"   #'dired-up-directory
	:n  "left"   #'dired-up-directory
	:n  "t"   #'dired-previous-line
	:n  "n"   #'dired-next-line
	:n  "s"   #'dired-find-file
	:n  "right"   #'dired-find-file
	:ng "a"   #'dirvish-quick-access
	:ng "f"   #'dirvish-file-info-menu
	:ng "y"   #'dirvish-yank-menu
	:ng "o"   #'dirvish-quicksort
	:ng "k"   #'dirvish-narrow
	:ng "TAB" #'dirvish-subtree-toggle
	:ng "M-t" #'dirvish-layout-toggle
	:ng "M-b" #'dirvish-history-go-backward
	:ng "M-f" #'dirvish-history-go-forward
	:ng "M-n" #'dirvish-narrow
	:ng "M-m" #'dirvish-mark-menu
	:ng "M-s" #'dirvish-setup-menu
	:ng "M-e" #'dirvish-emerge-menu)
  (setq dirvish-attributes
	'(all-the-icons file-size))
  (setq
   dirvish-use-header-line t
   dirvish-mode-line-format t
   dirvish-hide-details t
   dirvish-hide-cursor t))

(map! :leader
      :prefix "o"
      :desc "Dirvish"
      "-" #'dirvish)
(setq dirvish-use-header-line nil)

(defvar splash-phrase-source-folder
  (expand-file-name "splash-phrases" doom-private-dir)
  "A folder of text files with a fun phrase on each line.")

(defvar splash-phrase-sources
  (let* ((files (directory-files splash-phrase-source-folder nil "\\.txt\\'"))
	 (sets (delete-dups (mapcar
			     (lambda (file)
			       (replace-regexp-in-string "\\(?:-[0-9]+-\\w+\\)?\\.txt" "" file))
			     files))))
    (mapcar (lambda (sset)
	      (cons sset
		    (delq nil (mapcar
			       (lambda (file)
				 (when (string-match-p (regexp-quote sset) file)
				   file))
			       files))))
	    sets))
  "A list of cons giving the phrase set name, and a list of files which contain phrase components.")

(defvar splash-phrase-set
  (nth (random (length splash-phrase-sources)) (mapcar #'car splash-phrase-sources))
  "The default phrase set. See `splash-phrase-sources'.")

(defun splase-phrase-set-random-set ()
  "Set a new random splash phrase set."
  (interactive)
  (setq splash-phrase-set
	(nth (random (1- (length splash-phrase-sources)))
	     (cl-set-difference (mapcar #'car splash-phrase-sources) (list splash-phrase-set))))
  (+doom-dashboard-reload t))

(defvar splase-phrase--cache nil)

(defun splash-phrase-get-from-file (file)
  "Fetch a random line from FILE."
  (let ((lines (or (cdr (assoc file splase-phrase--cache))
		   (cdar (push (cons file
				     (with-temp-buffer
				       (insert-file-contents (expand-file-name file splash-phrase-source-folder))
				       (split-string (string-trim (buffer-string)) "\n")))
			       splase-phrase--cache)))))
    (nth (random (length lines)) lines)))

(defun splash-phrase (&optional set)
  "Construct a splash phrase from SET. See `splash-phrase-sources'."
  (mapconcat
   #'splash-phrase-get-from-file
   (cdr (assoc (or set splash-phrase-set) splash-phrase-sources))
   " "))

(defun doom-dashboard-phrase ()
  "Get a splash phrase, flow it over multiple lines as needed, and make fontify it."
  (mapconcat
   (lambda (line)
     (+doom-dashboard--center
      +doom-dashboard--width
      (with-temp-buffer
	(insert-text-button
	 line
	 'action
	 (lambda (_) (+doom-dashboard-reload t))
	 'face 'doom-dashboard-menu-title
	 'mouse-face 'doom-dashboard-menu-title
	 'help-echo "Random phrase"
	 'follow-link t)
	(buffer-string))))
   (split-string
    (with-temp-buffer
      (insert (splash-phrase))
      (setq fill-column (min 70 (/ (* 2 (window-width)) 3)))
      (fill-region (point-min) (point-max))
      (buffer-string))
    "\n")
   "\n"))

(defadvice! doom-dashboard-widget-loaded-with-phrase ()
  :override #'doom-dashboard-widget-loaded
  (setq line-spacing 0.2)
  (insert
   "\n\n"
   (propertize
    (+doom-dashboard--center
     +doom-dashboard--width
     (doom-display-benchmark-h 'return))
    'face 'doom-dashboard-loaded)
   "\n"
   (doom-dashboard-phrase)
   "\n"))

(defun doom-dashboard-draw-ascii-emacs-banner-fn ()
  (let* ((banner
	  '(",---.,-.-.,---.,---.,---."
	    "|---'| | |,---||    `---."
	    "`---'` ' '`---^`---'`---'"))
	 (longest-line (apply #'max (mapcar #'length banner))))
    (put-text-property
     (point)
     (dolist (line banner (point))
       (insert (+doom-dashboard--center
		+doom-dashboard--width
		(concat
		 line (make-string (max 0 (- longest-line (length line)))
				   32)))
	       "\n"))
     'face 'doom-dashboard-banner)))

(unless (display-graphic-p) ; for some reason this messes up the graphical splash screen atm
  (setq +doom-dashboard-ascii-banner-fn #'doom-dashboard-draw-ascii-emacs-banner-fn))

(defvar fancy-splash-image-template
  (expand-file-name "splash/doom-emacs-splash-template.svg" doom-private-dir)
  "Default template svg used for the splash image, with substitutions from ")

(defvar fancy-splash-sizes
  `((:height 500 :min-height 50 :padding (0 . 2))
    (:height 450 :min-height 42 :padding (2 . 4))
    (:height 400 :min-height 35 :padding (3 . 3))
    (:height 350 :min-height 28 :padding (3 . 3))
    (:height 200 :min-height 20 :padding (2 . 2))
    (:height 150  :min-height 15 :padding (2 . 1))
    (:height 100  :min-height 13 :padding (2 . 1))
    (:height 75  :min-height 12 :padding (2 . 1))
    (:height 50  :min-height 10 :padding (1 . 0))
    (:height 1   :min-height 0  :padding (0 . 0)))
  "list of plists with the following properties
  :height the height of the image
  :min-height minimum `frame-height' for image
  :padding `+doom-dashboard-banner-padding' (top . bottom) to apply
  :template non-default template file
  :file file to use instead of template")

(defvar fancy-splash-template-colours
  '(("$color1" . functions) ("$color2" . keywords) ("$color3" .  highlight) ("$color4" . bg) ("$color5" . bg) ("$color6" . base0))
  ;; 1: Text up, 2: Text low, 3: upper outlines, 4: Shadow, 5: Background, 6: Gradient to middle
  "list of colour-replacement alists of the form (\"$placeholder\" . 'theme-colour) which applied the template")

(unless (file-exists-p (expand-file-name "theme-splashes" doom-cache-dir))
  (make-directory (expand-file-name "theme-splashes" doom-cache-dir) t))

(defun fancy-splash-filename (theme-name height)
  (expand-file-name (concat (file-name-as-directory "theme-splashes")
			    theme-name
			    "-" (number-to-string height) ".svg")
		    doom-cache-dir))

(defun fancy-splash-clear-cache ()
  "Delete all cached fancy splash images"
  (interactive)
  (delete-directory (expand-file-name "theme-splashes" doom-cache-dir) t)
  (message "Cache cleared!"))

(defun fancy-splash-generate-image (template height)
  "Read TEMPLATE and create an image if HEIGHT with colour substitutions as
   described by `fancy-splash-template-colours' for the current theme"
  (with-temp-buffer
    (insert-file-contents template)
    (re-search-forward "$height" nil t)
    (replace-match (number-to-string height) nil nil)
    (replace-match (number-to-string height) nil nil)
    (dolist (substitution fancy-splash-template-colours)
      (goto-char (point-min))
      (while (re-search-forward (car substitution) nil t)
	(replace-match (doom-color (cdr substitution)) nil nil)))
    (write-region nil nil
		  (fancy-splash-filename (symbol-name doom-theme) height) nil nil)))

(defun fancy-splash-generate-images ()
  "Perform `fancy-splash-generate-image' in bulk"
  (dolist (size fancy-splash-sizes)
    (unless (plist-get size :file)
      (fancy-splash-generate-image (or (plist-get size :template)
				       fancy-splash-image-template)
				   (plist-get size :height)))))

(defun ensure-theme-splash-images-exist (&optional height)
  (unless (file-exists-p (fancy-splash-filename
			  (symbol-name doom-theme)
			  (or height
			      (plist-get (car fancy-splash-sizes) :height))))
    (fancy-splash-generate-images)))

(defun get-appropriate-splash ()
  (let ((height (frame-height)))
    (cl-some (lambda (size) (when (>= height (plist-get size :min-height)) size))
	     fancy-splash-sizes)))

(setq fancy-splash-last-size nil)
(setq fancy-splash-last-theme nil)
(defun set-appropriate-splash (&rest _)
  (let ((appropriate-image (get-appropriate-splash)))
    (unless (and (equal appropriate-image fancy-splash-last-size)
		 (equal doom-theme fancy-splash-last-theme)))
    (unless (plist-get appropriate-image :file)
      (ensure-theme-splash-images-exist (plist-get appropriate-image :height)))
    (setq fancy-splash-image
	  (or (plist-get appropriate-image :file)
	      (fancy-splash-filename (symbol-name doom-theme) (plist-get appropriate-image :height))))
    (setq +doom-dashboard-banner-padding (plist-get appropriate-image :padding))
    (setq fancy-splash-last-size appropriate-image)
    (setq fancy-splash-last-theme doom-theme)
    (+doom-dashboard-reload)))

(add-hook 'window-size-change-functions #'set-appropriate-splash)
;; (add-hook 'doom-load-theme-hook #'set-appropriate-splash)

(map! (:leader
       (:prefix-map ("c" . "code")
	:desc "jump to def other window"              "h" #'xref-find-definitions-other-window
	:desc "jump to def other frame"              "H" #'xref-find-definitions-other-frame)))

(global-tree-sitter-mode)
(define-key evil-outer-text-objects-map "f" (evil-textobj-tree-sitter-get-textobj "function.outer"))
(define-key evil-inner-text-objects-map "f" (evil-textobj-tree-sitter-get-textobj "function.inner"))
(define-key evil-outer-text-objects-map "i" (evil-textobj-tree-sitter-get-textobj "conditional.outer"))
(define-key evil-inner-text-objects-map "i" (evil-textobj-tree-sitter-get-textobj "conditional.inner"))
(define-key evil-outer-text-objects-map "l" (evil-textobj-tree-sitter-get-textobj "loop.outer"))
(define-key evil-inner-text-objects-map "l" (evil-textobj-tree-sitter-get-textobj "loop.inner"))
(define-key evil-inner-text-objects-map "c" (evil-textobj-tree-sitter-get-textobj "comment.inner"))

(defun my/comment-line-and-move-down ()
  (interactive)
  (comment-line 1))

(defun my/append-line-comment-block ()
  "Appends a new line after a comment block without expanding it.
Calls `evil-append-line` and `+default/newline` in sequence."
  (interactive)
  (call-interactively 'evil-append-line)
  (call-interactively '+default/newline)
  )
(map!
 (:prefix "g"
  :desc "New line after comment block" :n "o" #'my/append-line-comment-block
  ))

(use-package visual-regexp
  :commands vr/query-replace
  :config
  (setq vr/default-replace-preview nil)
  (setq vr/match-separator-use-custom-face t))
(use-package re-builder
  :config
  (setq reb-re-syntax 'string))

(use-package! lsp-mode
  :ensure
  :commands lsp
  :custom
  ;; what to use when checking on-save. "check" is default, I prefer clippy
  (lsp-rust-analyzer-cargo-watch-command "clippy")
  (lsp-eldoc-render-all nil)
  (lsp-idle-delay 0.6)
  (lsp-rust-analyzer-server-display-inlay-hints t)
  (lsp-rust-analyzer-display-lifetime-elision-hints-enable "skip_trivial")
  (lsp-rust-analyzer-display-chaining-hints t)
  (lsp-rust-analyzer-display-lifetime-elision-hints-use-parameter-names nil)
  (lsp-rust-analyzer-display-closure-return-type-hints t)
  (lsp-rust-analyzer-display-parameter-hints nil)
  (lsp-rust-analyzer-display-reborrow-hints nil)
  (lsp-signature-auto-activate nil) ;; you could manually request them via `lsp-signature-activate`
  (lsp-signature-render-documentation nil)
  (read-process-output-max (* 1024 1024)) ;; 1mb
  (flycheck-check-syntax-automatically '(mode-enabled save idle-change new-line))
  (lsp-headerline-breadcrumb-mode t)
  (lsp-completion-show-detail nil)
  (lsp-lens-enable nil)
  :config
  (add-hook 'lsp-mode-hook 'lsp-ui-mode))

(use-package! lsp-ui
  :ensure
  :commands lsp-ui-mode
  :custom
  (lsp-ui-doc-enable t)
  (lsp-ui-doc-delay 0.5)
  (lsp-ui-peek-always-show t)
  (lsp-ui-sideline-show-hover nil)
  (lsp-ui-doc-position 'top))
;; (lsp-ui-mode-show-with-cursor t)
;; (lsp-ui-mode-show-with-point t)

(use-package! dap-mode
  :ensure
  :config
  (dap-ui-mode)
  (dap-ui-controls-mode 1)
  ;; (require 'dap-lldb)
  (require 'dap-cpptools)
  ;; (require 'dap-gdb-lldb)
  ;; installs .extension/vscode
  ;; (dap-gdb-lldb-setup)
  (dap-cpptools-setup)
  (dap-register-debug-template "Rust::CppTools Run Configuration"
                               (list :type "cppdbg"
                                     :request "launch"
                                     :name "Rust::Run"
                                     :MIMode "gdb"
                                     :miDebuggerPath "rust-gdb"
                                     :environment []
                                     :program "${workspaceFolder}/target/debug/REPLACETHIS"
                                     :cwd "${workspaceFolder}"
                                     :console "external"
                                     :dap-compilation "cargo build"
                                     :dap-compilation-dir "${workspaceFolder}")))
(with-eval-after-load 'dap-mode
  (setq dap-default-terminal-kind "integrated") ;; Make sure that terminal programs open a term for I/O in an Emacs buffer
  (dap-auto-configure-mode +1))

(after! rustic
  (setq rustic-lsp-server 'rust-analyzer)
  (parinfer-rust-mode))

(setq lsp-clients-clangd-args '("-j=3"
				"--background-index"
				"--clang-tidy"
				"--completion-style=detailed"
				"--header-insertion=never"
				"--header-insertion-decorators=0"))
(after! lsp-clangd (set-lsp-priority! 'clangd 2))

(setq sh-basic-offset 2
      sh-indentation 2)

(eval-after-load 'ebuild-mode `(setq ebuild-log-buffer-mode 'ebuild-run-mode))

(require 'company-ebuild)
(after! ebuild-mode
  (set-company-backend! 'ebuild-mode  'company-shell 'company-ebuild))

(map! :localleader
      :map ebuild-mode-map
      "r" #'ebuild-run-command                ;; run a provided phase of the currently open ebuild
      "k" #'ebuild-mode-keyword               ;; change status of a single keyword e.g. from unstable to stable
      "s" #'ebuild-mode-insert-skeleton       ;; insert a skeleton of an ebuild to work from
      "u" #'ebuild-mode-all-keywords-unstable ;; mark all keywords unstable (~)
      "e" #'ebuild-mode-ekeyword              ;; run ekeyword on the current ebuild.
      "p" #'ebuild-mode-run-pkgdev            ;; run pgkdev command
      "c" #'ebuild-mode-run-pkgcheck          ;; run pgkcheck command
      "t" #'ebuild-mode-insert-tag-line       ;; Insert a tag with name and email
      "w" #'ebuild-mode-find-workdir          ;; Goto work dir of the ebuild
      )

(map! :leader
      :desc "Insert my tagline"           "T" #'ebuild-mode-insert-tag-line)

(defun ebuild-mode-set-CC-clang ()
  (interactive)
  (setenv "CC" "clang")
  (setenv "CXX" "clang++"))

(defun ebuild-mode-set-CC-gcc ()
  (interactive)
  (setenv "CC" "gcc")
  (setenv "CXX" "g++"))

(defun ebuilds/scrub-patch (&optional @fname)
  "Call scrub-patch on marked file in dired or on current file.
 Needs app-portage/iwdevtools.
 Got this from xah lee, modified a bit
 URL `http://xahlee.info/emacs/emacs/emacs_dired_open_file_in_ext_apps.html'"
  (interactive)
  (let* (
	 ($file-list
	  (if @fname
	      (progn (list @fname))
	    (if (string-equal major-mode "dired-mode")
		(dired-get-marked-files)
	      (list (buffer-file-name)))))
	 ($do-it-p (if (<= (length $file-list) 5)
		       t
		     (y-or-n-p "Scrub more than 5 files? "))))
    (when $do-it-p
      (mapc
       (lambda ($fpath)
	 (shell-command
	  (concat "scrub-patch -c -i " (shell-quote-argument $fpath))))  $file-list)
      (when (not (string-equal major-mode "dired-mode"))
	(revert-buffer)))))

(use-package! copilot
  :hook (prog-mode . copilot-mode)
  :bind* (("C-<backtab>" . 'copilot-accept-completion-by-word)
          :map copilot-completion-map
          ("<backtab>" . 'copilot-accept-completion))
  :config
  ;; Upon entering copilot mode, disable smartparens-mode as it is incompatible
  (add-hook 'copilot-mode-hook #'turn-off-smartparens-mode)
  ;; Only enable copilot in insert mode and immediately after entering insert mode
  (setq copilot-enable-predicates '(evil-insert-state-p)))

(add-to-list 'load-path "/usr/share/emacs/site-lisp/mu4e")
(after! mu4e
  (require 'mu4e)
  (require 'smtpmail)
  (setq user-mail-address "pascal.jaeger@leimstift.de"
	user-full-name  "Pascal Jaeger"
	mu4e-get-mail-command "mbsync -c ~/.config/mu4e/mbsyncrc -a"
	mu4e-update-interval  300
	mu4e-compose-signature
	(concat
	 "Mit freundlichen Gruessen\n"
	 "Pascal Jaeger\n")
	message-send-mail-function 'smtpmail-send-it
	starttls-use-gnutls t
	smtpmail-starttls-credentials '(("sslout.df.eu" 587 nil nil))
	smtpmail-auth-credentials '(("sslout.df.eu" 587 "pascal.jaeger@leimtift.de" nil))
	smtpmail-default-smtp-server "sslout.df.eu"
	smtpmail-smtp-server "sslout.df.eu"
	smtpmail-smtp-service 587
	mu4e-sent-folder "/pascal-leimstift/Sent"
	mu4e-drafts-folder "/pascal-leimstift/Drafts"
	mu4e-trash-folder "/pascal-leimstift/Trash"
	mu4e-refile-folder "/All Mail"
	mu4e-sent-messages-behavior 'sent
	mu4e-maildir-shortcuts
	'(("/pascal-leimstift/Inbox"    . ?i)
	  ("/pascal-leimstift/Sent"     . ?s)
	  ("/pascal-leimstift/Drafts"   . ?d)
	  ("/pascal-leimstift/Trash"    . ?t)
	  ("/All Mail" . ?a)
	  )))

;; PGP-Sign all e-mails
(add-hook 'message-send-hook 'mml-secure-message-sign-pgp)

(setq auth-sources '("~/.authinfo.gpg"))

(defun my-fetch-password (&rest params)
  (require 'auth-source)
  (let ((match (car (apply #'auth-source-search params))))
    (if match
	(let ((secret (plist-get match :secret)))
	  (if (functionp secret)
	      (funcall secret)
	    secret))
      (error "Password not found for %S" params))))

(defun my-nickserv-password (server)
  (my-fetch-password :user "Schievel" :machine "irc.libera.chat"))

(setq circe-network-options
      '(("Libera Chat"
	 :reduce-lurker-spam t
	 :tls t
	 :port 6697
	 :nick "Schievel"
	 :sasl-username "Schievel"
	 :sasl-password my-nickserv-password
	 :nickserv-password my-nickserv-password
	 :channels ("#emacs" "#emacs-circe" "#gentoo-desktop" "#gentoo" "#gentoo-guru" "#gentoo-dev" "#gentoo-chat" "#gentoo-lisp" "#gentoo-rust" "#gentoo-dev-help" "#gentoo-toolchain" "#gentoo-de")
	 )))
(setq lui-autopaste-lines 2)

(require 'lui-autopaste)
(add-hook 'circe-channel-mode-hook 'enable-lui-autopaste)
(add-hook 'circe-chat-mode-hook 'my-circe-prompt)
(defun my-circe-prompt ()
  (lui-set-prompt
   (concat (propertize (concat (car (split-string (buffer-name) "@")) ">")
		       'face 'circe-prompt-face)
	   " ")))

(load "lui-logging" nil t)
(enable-lui-logging-globally)

(setq calendar-week-start-day 1)

(defun org-caldav-sync-at-close ()
  (org-caldav-sync)
  (save-some-buffers))

;; This is the delayed sync function; it waits until emacs has been idle for
;; "secs" seconds before syncing.  The delay is important because the caldav-sync
;; can take five or ten seconds, which would be painful if it did that right at save.
;; This way it just waits until you've been idle for a while to avoid disturbing
;; the user.
(defvar org-caldav-sync-timer nil
  "Timer that `org-caldav-push-timer' used to reschedule itself, or nil.")
(defun org-caldav-sync-with-delay (secs)
  (when org-caldav-sync-timer
    (cancel-timer org-caldav-sync-timer))
  (setq org-caldav-sync-timer
	(run-with-idle-timer
	 (* 1 secs) nil 'org-caldav-sync)))
;;config
(setq org-caldav-url "https://pascal.leimstift.de/remote.php/dav/calendars/pascal")
(setq org-caldav-calendars
      '((:calendar-id "personal" :files ("~/org/agenda/personal-cal.org")
	 :inbox "~/org/agenda/personal-caldav-inbox.org")

	(:calendar-id "fritzlar-kernstadt-2023ics-importiert" :files ("~/org/agenda/Muell-cal.org")
	 :inbox "~/org/agenda/Muell-caldav-inbox.org")
	)
      )
(setq org-icalendar-alarm-time 1)
;; This makes sure to-do items as a category can show up on the calendar
(setq org-icalendar-include-todo t)
;; This ensures all org "deadlines" show up, and show up as due dates
(setq org-icalendar-use-deadline '(event-if-todo event-if-not-todo todo-due))
;; This ensures "scheduled" org items show up, and show up as start times
(setq org-icalendar-use-scheduled '(todo-start event-if-todo event-if-not-todo))

;; This is the sync on close function; it also prompts for save after syncing so
;; no late changes get lost
(defun org-caldav-sync-at-close ()
  (org-caldav-sync)
  (save-some-buffers))

;; This is the delayed sync function; it waits until emacs has been idle for
;; "secs" seconds before syncing.  The delay is important because the caldav-sync
;; can take five or ten seconds, which would be painful if it did that right at save.
;; This way it just waits until you've been idle for a while to avoid disturbing
;; the user.
(defvar org-caldav-sync-timer nil
  "Timer that `org-caldav-push-timer' used to reschedule itself, or nil.")
(defun org-caldav-sync-with-delay (secs)
  (when org-caldav-sync-timer
    (cancel-timer org-caldav-sync-timer))
  (setq org-caldav-sync-timer
	(run-with-idle-timer
	 (* 1 secs) nil 'org-caldav-sync)))

(setq solar-n-hemi-seasons
      '("Frühlingsanfang" "Sommeranfang" "Herbstanfang" "Winteranfang"))

(setq holiday-general-holidays
      '((holiday-fixed 1 1 "Neujahr")
	(holiday-fixed 5 1 "1. Mai")
	(holiday-fixed 10 3 "Tag der Deutschen Einheit")))

;; Feiertage für Bayern, weitere auskommentiert
(setq holiday-christian-holidays
      '((holiday-float 12 0 -4 "1. Advent" 24)
	(holiday-float 12 0 -3 "2. Advent" 24)
	(holiday-float 12 0 -2 "3. Advent" 24)
	(holiday-float 12 0 -1 "4. Advent" 24)
	(holiday-fixed 12 25 "1. Weihnachtstag")
	(holiday-fixed 12 26 "2. Weihnachtstag")
	(holiday-fixed 1 6 "Heilige Drei Könige")
	(holiday-easter-etc -48 "Rosenmontag")
	;; (holiday-easter-etc -3 "Gründonnerstag")
	(holiday-easter-etc  -2 "Karfreitag")
	(holiday-easter-etc   0 "Ostersonntag")
	(holiday-easter-etc  +1 "Ostermontag")
	(holiday-easter-etc +39 "Christi Himmelfahrt")
	(holiday-easter-etc +49 "Pfingstsonntag")
	(holiday-easter-etc +50 "Pfingstmontag")
	(holiday-easter-etc +60 "Fronleichnam")
	(holiday-fixed 8 15 "Mariae Himmelfahrt")
	(holiday-fixed 11 1 "Allerheiligen")
	;; (holiday-float 11 3 1 "Buss- und Bettag" 16)
	(holiday-float 11 0 1 "Totensonntag" 20)))

(map! :leader
      (:prefix-map ("o" . "open")
       :desc "Calendar"	"c"  #'cfw:open-org-calendar
       :desc "IRC"		"i" #'=irc
       :desc "Mail"		"m"  #'mu4e))


