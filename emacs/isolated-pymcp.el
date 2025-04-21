;;; isolated-pymcp.el --- MCP integration for isolated-pymcp

;;; Commentary:
;; This file provides MCP integration for the isolated-pymcp project.

;;; Code:
(require 'mcp)

(defgroup isolated-pymcp nil
  "Settings for isolated-pymcp integration."
  :group 'tools)

(defcustom isolated-pymcp-run-python-url "http://localhost:3001"
  "URL for the Run-Python MCP server."
  :type 'string
  :group 'isolated-pymcp)

(defcustom isolated-pymcp-multilspy-url "http://localhost:3005"
  "URL for the MultilspyLSP MCP server."
  :type 'string
  :group 'isolated-pymcp)

(defun isolated-pymcp-connect-servers ()
  "Connect to all MCP servers defined for isolated-pymcp."
  (interactive)
  (mcp-add-server "run-python" isolated-pymcp-run-python-url)
  (mcp-add-server "multilspy" isolated-pymcp-multilspy-url)
  (message "Connected to isolated-pymcp MCP servers"))

(defun isolated-pymcp-run-buffer ()
  "Run current buffer using MCP run-python server."
  (interactive)
  (let ((code (buffer-substring-no-properties (point-min) (point-max))))
    (mcp-execute "run-python" "run" 
                 `(("code" . ,code))
                 (lambda (result)
                   (with-current-buffer (get-buffer-create "*MCP Run Result*")
                     (erase-buffer)
                     (insert "# Python Execution Result\n\n")
                     (insert "```\n")
                     (insert result)
                     (insert "\n```\n")
                     (goto-char (point-min))
                     (pop-to-buffer (current-buffer)))))))

(defun isolated-pymcp-analyze-buffer ()
  "Analyze current buffer with MultilspyLSP."
  (interactive)
  (let ((code (buffer-substring-no-properties (point-min) (point-max))))
    (mcp-execute "multilspy" "analyze"
                 `(("code" . ,code)
                   ("language" . "python"))
                 (lambda (result)
                   (with-current-buffer (get-buffer-create "*MCP Analysis*")
                     (erase-buffer)
                     (insert "# Python Analysis Result\n\n")
                     (when (assoc 'diagnostics result)
                       (insert "## Diagnostics\n\n")
                       (dolist (diag (cdr (assoc 'diagnostics result)))
                         (let ((range (cdr (assoc 'range diag)))
                               (message (cdr (assoc 'message diag)))
                               (severity (cdr (assoc 'severity diag))))
                           (insert (format "- %s: %s (Line %s)\n"
                                          (cond
                                           ((= severity 1) "Error")
                                           ((= severity 2) "Warning")
                                           ((= severity 3) "Info")
                                           ((= severity 4) "Hint")
                                           (t "Issue"))
                                          message
                                          (cdr (assoc 'line (cdr (assoc 'start range)))))))))
                     (goto-char (point-min))
                     (pop-to-buffer (current-buffer)))))))

(defun isolated-pymcp-get-completions ()
  "Get Python completions at point using LSP via MCP."
  (interactive)
  (let* ((code (buffer-substring-no-properties (point-min) (point-max)))
         (line (1- (line-number-at-pos)))  ; LSP uses zero-based line numbers
         (col (current-column))
         (buffer-name "*MCP Completions*"))
    (mcp-execute "multilspy" "completion"
                 `(("code" . ,code)
                   ("language" . "python")
                   ("line" . ,line)
                   ("character" . ,col))
                 (lambda (result)
                   (with-current-buffer (get-buffer-create buffer-name)
                     (erase-buffer)
                     (insert "# Completion Results\n\n")
                     (when (assoc 'items result)
                       (dolist (item (cdr (assoc 'items result)))
                         (let ((label (cdr (assoc 'label item)))
                               (kind (cdr (assoc 'kind item)))
                               (detail (cdr (assoc 'detail item))))
                           (insert (format "- `%s` (%s)\n  %s\n"
                                          label
                                          (cond
                                           ((= kind 2) "Method")
                                           ((= kind 3) "Function")
                                           ((= kind 6) "Variable")
                                           ((= kind 7) "Class")
                                           (t "Symbol"))
                                          (or detail ""))))))
                     (goto-char (point-min))
                     (pop-to-buffer (current-buffer)))))))

(defun isolated-pymcp-setup ()
  "Set up the isolated-pymcp environment."
  (interactive)
  (isolated-pymcp-connect-servers)
  (message "isolated-pymcp environment set up successfully"))

;; Key bindings
(defvar isolated-pymcp-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c C-r") 'isolated-pymcp-run-buffer)
    (define-key map (kbd "C-c C-a") 'isolated-pymcp-analyze-buffer)
    (define-key map (kbd "C-c C-c") 'isolated-pymcp-get-completions)
    map)
  "Keymap for isolated-pymcp-mode.")

;;;###autoload
(define-minor-mode isolated-pymcp-mode
  "Minor mode for isolated-pymcp MCP integration."
  :lighter " iso-mcp"
  :keymap isolated-pymcp-mode-map
  (if isolated-pymcp-mode
      (isolated-pymcp-setup)
    (message "isolated-pymcp-mode disabled")))

(provide 'isolated-pymcp)
;;; isolated-pymcp.el ends here
