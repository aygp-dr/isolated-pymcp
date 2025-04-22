;; Emacs Eglot Configuration

;; Install required packages
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(unless (package-installed-p 'eglot)
  (package-refresh-contents)
  (package-install 'eglot))

;; Configure Eglot
(require 'eglot)

;; Enable Eglot in Python mode
(add-hook 'python-mode-hook 'eglot-ensure)

;; Enable Eglot in JavaScript/TypeScript mode
(add-hook 'js-mode-hook 'eglot-ensure)
(add-hook 'typescript-mode-hook 'eglot-ensure)

;; Configure default servers if needed
(add-to-list 'eglot-server-programs
             '(python-mode . ("pylsp")))
(add-to-list 'eglot-server-programs
             '((js-mode typescript-mode) . ("typescript-language-server" "--stdio")))
