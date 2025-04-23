;; Emacs LSP Mode Configuration

;; Install required packages
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(unless (package-installed-p 'lsp-mode)
  (package-refresh-contents)
  (package-install 'lsp-mode))

(unless (package-installed-p 'lsp-ui)
  (package-install 'lsp-ui))

(unless (package-installed-p 'company)
  (package-install 'company))

;; Configure LSP Mode
(require 'lsp-mode)
(setq lsp-keymap-prefix "C-c l")

;; Configure LSP UI
(require 'lsp-ui)
(setq lsp-ui-doc-enable t
      lsp-ui-doc-position 'at-point
      lsp-ui-sideline-enable t
      lsp-ui-sideline-show-diagnostics t)

;; Configure company for completions
(require 'company)
(add-hook 'lsp-mode-hook 'company-mode)
(setq company-minimum-prefix-length 1
      company-idle-delay 0.0)

;; Enable LSP in Python mode
(add-hook 'python-mode-hook 'lsp)

;; Enable LSP in JavaScript/TypeScript mode
(add-hook 'js-mode-hook 'lsp)
(add-hook 'typescript-mode-hook 'lsp)
