;; Enable MCP Python for org-babel
(with-eval-after-load 'org
  (add-to-list 'org-babel-load-languages '(mcp-python . t))
  (org-babel-do-load-languages 'org-babel-load-languages org-babel-load-languages))

;; Optional: Don't ask for confirmation when executing MCP Python blocks
(defun my-org-confirm-babel-evaluate (lang body)
  (not (string= lang "mcp-python")))
(setq org-confirm-babel-evaluate 'my-org-confirm-babel-evaluate)
