;; straight.el does not use anything related
;; to package.el at all
(setq package-enable-at-startup nil)

;; native compilation loves to pop warnings
;; and does so INCESSANTLY
(setq comp-async-report-warnings-errors nil)
(setq warning-minimum-level :error)

