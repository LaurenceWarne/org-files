(require 'package)

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

;; git executable location
(add-to-list 'exec-path "/usr/bin")

(use-package quelpa
  :config
  ;; https://github.com/quelpa/quelpa-use-package
  (quelpa
   '(quelpa-use-package
     :fetcher git
     :url "https://github.com/quelpa/quelpa-use-package.git"))
  (require 'quelpa-use-package))

(use-package dash
  :demand t)

(use-package org
  :after dash
  :demand t
  :config
  (setq org-confirm-babel-evaluate nil)
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((python . t)
     (shell . t)
     (dot . t)
     (emacs-lisp . t)
     (haskell . t)))
  (add-to-list 'org-src-lang-modes '("haskell" . haskell-tng)))

(use-package org-contrib
  :after org
  :demand t)

(use-package scala-mode
  :mode "\\.s\\(c\\|cala\\|bt\\)$")

(use-package haskell-tng-mode
  :ensure nil
  :quelpa (haskell-tng-mode :fetcher gitlab :repo "tseenshe/haskell-tng.el")
  :mode ((rx ".hs" eos) . haskell-tng-mode)
  :bind
  (:map
   haskell-tng-mode-map
   ("RET" . haskell-tng-newline)
   ("C-c c" . haskell-tng-compile)
   ("C-c e" . next-error))
  :config
  (require 'haskell-tng-hsinspect)
  (require 'haskell-tng-extra)
  (require 'haskell-tng-extra-hideshow)
  (require 'haskell-tng-extra-company)
  (require 'haskell-tng-extra-projectile)
  (require 'haskell-tng-extra-smartparens))

(use-package htmlize)

(use-package ox-yaow
  :after org
  :demand t
  :config
  (setq org-publish-project-alist
        (append
         `(("wiki-pages"
            :base-directory "~/org/"
            :base-extension "org"
            :publishing-directory "~/wiki/"
            :html-head ,ox-yaow-html-head
            :html-preamble t
            :recursive t
            :exclude ".*steam.*"
            :publishing-function ox-yaow-publish-to-html
            :preparation-function ox-yaow-preparation-fn
            :completion-function ox-yaow-completion-fn
            :ox-yaow-wiki-home-file "~/org/wiki.org"
            :ox-yaow-file-blacklist ("~/org/maths/answers.org")
            :ox-yaow-depth 2)
           ("wiki-static"
            :base-directory "~/org/"
            :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg\\|swf"
            :publishing-directory "~/wiki/"
            :recursive t
            :exclude ,(rx (0+ ".") (or "steam" "ltximg") (0+ "."))
            :publishing-function org-publish-attachment)
           ("wiki"
            :components ("wiki-pages" "wiki-static")))
         org-publish-project-alist)))

(require 'org)
(require 'scala-mode)
(require 'haskell-tng-mode)
(require 'python)
(require 'ox-yaow)
(require 'htmlize)

;; https://emacs.stackexchange.com/questions/31439/how-to-get-colored-syntax-highlighting-of-code-blocks-in-asynchronous-org-mode-e
(setq org-html-htmlize-output-type 'css)
(message "Running publish...")
(org-publish-project "wiki")
