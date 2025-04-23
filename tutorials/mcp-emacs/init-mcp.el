;; Add the directory to your load path
(add-to-list 'load-path "~/.emacs.d/lisp/")

;; Load MCP package
(require 'mcp)

;; MCP - Model Context Protocol integration

;; Add the directory to your load path
(add-to-list 'load-path "~/.emacs.d/lisp/")

;; Load MCP.el
(require 'mcp)

;; Configure MCP server timeout
(setq mcp-default-timeout 30000)

;; Enable MCP for org-babel
(with-eval-after-load 'org
  (add-to-list 'org-babel-load-languages '(mcp-python . t))
  (org-babel-do-load-languages 'org-babel-load-languages org-babel-load-languages))
