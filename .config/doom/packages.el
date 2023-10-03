;; -*- no-byte-compile: t; -*-

(package! org-caldav)
(package! calfw-ical)
(package! nyan-mode)

(package! emacs-htmlize :recipe (:host github :repo "hniksic/emacs-htmlize"))
(package! smtpmail)

(unpin! org-roam)
(package! org-roam-ui)
(package! org2blog)
(package! el-easydraw
   :recipe (:host github :repo "misohena/el-easydraw"))

(package! harpoon)


(package! prism
  :recipe (:host github :repo "alphapapa/prism.el"))
(package! copilot
  :recipe (:host github :repo "zerolfx/copilot.el" :files ("*.el" "dist")))
;;(package! company-tabnine :recipe (:host github :repo "TommyX12/company-tabnine"))

(package! visual-regexp)
(package! re-builder)
(package! org-side-tree
  :recipe (:host github :repo "localauthor/org-side-tree"))

;;(package! edwina)
(package! ement)
(package! elcord)
