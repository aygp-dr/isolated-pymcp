;; Project-specific Emacs settings
((nil . ((fill-column . 100)
         (indent-tabs-mode . nil)))
 (org-mode . ((org-confirm-babel-evaluate . nil)))
 (python-mode . ((python-indent-offset . 4)
                 (flycheck-python-flake8-executable . "python3")
                 (flycheck-python-pylint-executable . "python3"))))
