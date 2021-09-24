(require 'package)
(require 'org)

(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (proto (if no-ssl "http" "https")))
  ;; Comment/uncomment these two lines to enable/disable MELPA and MELPA Stable as desired
  (add-to-list 'package-archives (cons "melpa" (concat proto "://melpa.org/packages/")) t)
  
  ;;(add-to-list 'package-archives (cons "melpa-stable" (concat proto "://stable.melpa.org/packages/")) t)
  (when (< emacs-major-version 24)
    ;; For important compatibility libraries like cl-lib
    (add-to-list 'package-archives '("gnu" . (concat proto "://elpa.gnu.org/packages/")))))
(add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/") t)  ; Get most recent versions of org mode

(package-initialize)

;; Check if use-package is installed and install if it's not
;; Note it's a melpa package so this has to come after the melpa repository is added
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package)
  (require 'use-package))

(setq use-package-always-ensure t)

(use-package dash)

(use-package elpy
  ;; Enable Elpy in all future Python buffers.
  :init (elpy-enable)
  :config (setq elpy-rpc-python-command "python3")
  ;; Fix python does not support readline warning
  (setq python-shell-completion-native-enable nil))

(use-package org
  :after dash
  :ensure org-plus-contrib
  :config
  (setq org-confirm-babel-evaluate nil)
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((python . t)
     (shell . t)
     (emacs-lisp . t)))
  ;; Horrfic hack to disable highlight-indent-mode in python snippets
  ;; which are exported to html using org export.
  ;; See the defintion of `org-html-fontify-code' for why this works
  (defun python-no-elpy-mode ()
    (interactive)
    (let (python-mode-hook)
      (python-mode)))
  (add-to-list 'org-src-lang-modes '("python" . python-no-elpy))
  :pin org)

(use-package scala-mode
  :mode "\\.s\\(c\\|cala\\|bt\\)$")

(use-package htmlize)

(use-package ox-yaow
  :after org
  :config
  ;; Stolen from https://github.com/fniessen/org-html-themes
  (setq rto-css '("https://fniessen.github.io/org-html-themes/src/readtheorg_theme/css/htmlize.css"
                  "https://fniessen.github.io/org-html-themes/src/readtheorg_theme/css/readtheorg.css")
        rto-js '("https://fniessen.github.io/org-html-themes/src/lib/js/jquery.stickytableheaders.min.js"
                 "https://fniessen.github.io/org-html-themes/src/readtheorg_theme/js/readtheorg.js")
        extra-js '("https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js"
                   "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/js/bootstrap.min.js" )
        ox-yaow-html-head
        (concat
         (mapconcat
          (lambda (url)
            (concat "<link rel=\"stylesheet\" type=\"text/css\" href=\""
                    url
                    "\"/>\n"))
          rto-css
          "")
         (mapconcat
          (lambda (url)
            (concat "<script src=\"" url "\"></script>\n"))
          (append rto-js extra-js) "")
         "<link rel=\"stylesheet\" type=\"text/css\" href=\"https://raw.githubusercontent.com/LaurenceWarne/org-files/master/style-sheets.css\" />")
        org-publish-project-alist (cons
                                   `("wiki"
                                     :base-directory "/org/"
                                     :base-extension "org"
                                     :publishing-directory "/wiki/"
                                     :html-head ,ox-yaow-html-head
                                     :html-preamble t
                                     :htmlized-source t
                                     :recursive t
                                     :exlude ".*steam\.org"
                                     :publishing-function ox-yaow-publish-to-html
                                     :preparation-function ox-yaow-preparation-fn
                                     :completion-function ox-yaow-completion-fn
                                     :ox-yaow-wiki-home-file "/org/wiki.org"

                                     :ox-yaow-file-blacklist ("org/maths/answers.org")
                                     :ox-yaow-depth 2)
                                   org-publish-project-alist)))

(require 'org)
(require 'scala-mode)
(require 'python)
(require 'ox-yaow)
(require 'htmlize)

;; https://emacs.stackexchange.com/questions/31439/how-to-get-colored-syntax-highlighting-of-code-blocks-in-asynchronous-org-mode-e
(setq org-html-htmlize-output-type 'css)
(message "Running publish...")
(org-publish-project "wiki")
