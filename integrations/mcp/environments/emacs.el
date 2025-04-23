;;; mcp.el --- Model Context Protocol integration for Emacs -*- lexical-binding: t; -*-

;; Author: Jason Walsh <jwalsh@defrecord.com>
;; Version: 0.1.0
;; Package-Requires: ((emacs "27.1") (json "1.5") (request "0.3.2"))
;; Keywords: tools, ai, mcp
;; URL: https://github.com/jwalsh/isolated-pymcp

;;; Commentary:
;; Provides integration with Model Context Protocol servers for Emacs.
;; This allows running isolated Python code and other MCP-enabled services.

;;; Code:

(require 'json)
(require 'request)

(defgroup mcp nil
  "Settings for Model Context Protocol integration."
  :group 'tools
  :prefix "mcp-")

(defcustom mcp-servers-alist
  '((run-python . ("deno" "run" "-N" "-R=node_modules" "-W=node_modules" "--node-modules-dir=auto" "--allow-read=." "jsr:@pydantic/mcp-run-python" "stdio"))
    (memory . ("npx" "-y" "@modelcontextprotocol/server-memory"))
    (filesystem . ("npx" "-y" "@modelcontextprotocol/server-filesystem"))
    (github . ("npx" "-y" "@modelcontextprotocol/server-github")))
  "Alist of MCP servers and their start commands."
  :type '(alist :key-type symbol :value-type (repeat string))
  :group 'mcp)

(defcustom mcp-default-timeout 30000
  "Default timeout in milliseconds for MCP requests."
  :type 'integer
  :group 'mcp)

(defcustom mcp-log-level "info"
  "Log level for MCP operations."
  :type '(choice (const "debug") (const "info") (const "warn") (const "error"))
  :group 'mcp)

;; Process management for MCP servers
(defvar mcp--server-processes nil
  "Alist of running MCP server processes.")

(defun mcp-start-server (server-type)
  "Start an MCP server of type SERVER-TYPE."
  (interactive (list (completing-read "Server type: " (mapcar #'car mcp-servers-alist))))
  (let* ((server-type-sym (if (symbolp server-type) server-type (intern server-type)))
         (command-args (alist-get server-type-sym mcp-servers-alist))
         (proc-name (format "mcp-%s" server-type-sym))
         (buffer-name (format "*%s*" proc-name)))
    (when (process-live-p (alist-get server-type-sym mcp--server-processes))
      (user-error "MCP %s server is already running" server-type-sym))
    (let ((proc (apply #'start-process proc-name buffer-name command-args)))
      (setf (alist-get server-type-sym mcp--server-processes) proc)
      (message "Started MCP %s server" server-type-sym)
      proc)))

(defun mcp-stop-server (server-type)
  "Stop the MCP server of type SERVER-TYPE."
  (interactive (list (completing-read "Server type: " 
                                      (mapcar #'car mcp--server-processes))))
  (let* ((server-type-sym (if (symbolp server-type) server-type (intern server-type)))
         (proc (alist-get server-type-sym mcp--server-processes)))
    (when (process-live-p proc)
      (delete-process proc)
      (setf (alist-get server-type-sym mcp--server-processes) nil)
      (message "Stopped MCP %s server" server-type-sym))))

(defun mcp-start-all-servers ()
  "Start all configured MCP servers."
  (interactive)
  (dolist (server (mapcar #'car mcp-servers-alist))
    (mcp-start-server server)))

(defun mcp-stop-all-servers ()
  "Stop all running MCP servers."
  (interactive)
  (dolist (server (mapcar #'car mcp--server-processes))
    (mcp-stop-server server)))

;; MCP function calls
(defun mcp-call-function (server-type method &optional params)
  "Call METHOD on SERVER-TYPE MCP server with optional PARAMS."
  (unless (alist-get server-type mcp--server-processes)
    (mcp-start-server server-type))
  (let ((url (format "http://localhost:%d" 
                     (pcase server-type
                       ('run-python 3001)
                       ('memory 3002)
                       ('filesystem 3003)
                       ('github 3004)
                       (_ (user-error "Unknown server type: %s" server-type)))))
        (request-data (json-encode 
                       `(("jsonrpc" . "2.0")
                         ("method" . ,method)
                         ("params" . ,(or params :json-null))
                         ("id" . 1)))))
    (with-current-buffer (get-buffer-create "*mcp-result*")
      (erase-buffer)
      (request url
        :type "POST"
        :data request-data
        :headers '(("Content-Type" . "application/json"))
        :parser 'json-read
        :sync t
        :timeout mcp-default-timeout
        :success (cl-function
                  (lambda (&key data &allow-other-keys)
                    (with-current-buffer "*mcp-result*"
                      (insert (json-encode data))
                      (json-pretty-print-buffer)
                      (display-buffer (current-buffer)))))
        :error (cl-function
                (lambda (&key error-thrown &allow-other-keys)
                  (with-current-buffer "*mcp-result*"
                    (insert (format "Error: %S" error-thrown))
                    (display-buffer (current-buffer))))))
      (current-buffer))))

;; Python execution specific functions
(defun mcp-run-python-code (code)
  "Run Python CODE using MCP run-python server."
  (interactive "sPython code: ")
  (mcp-call-function 'run-python "tools/call" 
                     `(("name" . "run_python_code")
                       ("arguments" . (("python_code" . ,code))))))

(defun mcp-run-python-region (start end)
  "Run Python code in region from START to END using MCP."
  (interactive "r")
  (mcp-run-python-code (buffer-substring-no-properties start end)))

;; Org-babel integration for MCP Python
(defun org-babel-execute:mcp-python (body params)
  "Execute Python BODY code block using MCP with PARAMS."
  (with-temp-buffer
    (insert body)
    (let ((result (mcp-run-python-code body)))
      (with-current-buffer result
        (let* ((json-object-type 'plist)
               (json-data (json-read-from-string (buffer-string)))
               (content (plist-get (plist-get (plist-get json-data :result) :content) 0))
               (output-text (plist-get content :text)))
          output-text)))))

;; Register the org-babel language
(with-eval-after-load 'org
  (add-to-list 'org-babel-load-languages '(mcp-python . t))
  (org-babel-do-load-languages 'org-babel-load-languages org-babel-load-languages))

(provide 'mcp)
;;; mcp.el ends here
