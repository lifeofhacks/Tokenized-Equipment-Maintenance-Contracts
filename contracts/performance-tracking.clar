;; Performance Tracking Contract
;; Monitors equipment uptime and issues

;; Data structure for equipment performance
(define-map equipment-performance uint
  {
    total-uptime: uint,          ;; in hours
    total-downtime: uint,        ;; in hours
    last-status-update: uint,    ;; block height
    current-status: (string-ascii 20),  ;; "operational", "maintenance", "down"
    issues-count: uint
  }
)

;; Data structure for tracking issues
(define-map equipment-issues (tuple (equipment-id uint) (issue-id uint))
  {
    timestamp: uint,
    description: (string-ascii 500),
    severity: (string-ascii 20),  ;; "low", "medium", "high", "critical"
    resolved: bool,
    resolution-timestamp: uint,
    resolution-description: (optional (string-ascii 500))
  }
)

;; Counter for issue IDs per equipment
(define-map issue-id-counter uint uint)

;; Initialize equipment performance tracking
(define-public (initialize-performance-tracking (equipment-id uint))
  (begin
    ;; Initialize performance data
    (map-set equipment-performance equipment-id {
      total-uptime: u0,
      total-downtime: u0,
      last-status-update: block-height,
      current-status: "operational",
      issues-count: u0
    })

    ;; Initialize issue counter
    (map-set issue-id-counter equipment-id u1)

    (ok true)
  )
)

;; Update equipment status
(define-public (update-equipment-status (equipment-id uint) (new-status (string-ascii 20)))
  (let (
    (performance (unwrap! (map-get? equipment-performance equipment-id) (err u404)))
    (current-time block-height)
    (time-since-last-update (- current-time (get last-status-update performance)))
  )
    ;; Calculate uptime/downtime based on previous status
    (let (
      (updated-uptime (if (is-eq (get current-status performance) "operational")
                        (+ (get total-uptime performance) time-since-last-update)
                        (get total-uptime performance)))
      (updated-downtime (if (is-eq (get current-status performance) "down")
                          (+ (get total-downtime performance) time-since-last-update)
                          (get total-downtime performance)))
    )
      ;; Update performance data
      (map-set equipment-performance equipment-id {
        total-uptime: updated-uptime,
        total-downtime: updated-downtime,
        last-status-update: current-time,
        current-status: new-status,
        issues-count: (get issues-count performance)
      })

      (ok true)
    )
  )
)

;; Report an equipment issue
(define-public (report-issue
    (equipment-id uint)
    (description (string-ascii 500))
    (severity (string-ascii 20))
  )
  (let (
    (performance (unwrap! (map-get? equipment-performance equipment-id) (err u404)))
    (issue-id (default-to u1 (map-get? issue-id-counter equipment-id)))
  )
    ;; Record the issue
    (map-set equipment-issues (tuple (equipment-id equipment-id) (issue-id issue-id)) {
      timestamp: block-height,
      description: description,
      severity: severity,
      resolved: false,
      resolution-timestamp: u0,
      resolution-description: none
    })

    ;; Update issue counter
    (map-set issue-id-counter equipment-id (+ issue-id u1))

    ;; Update issues count in performance data
    (map-set equipment-performance equipment-id (merge performance {
      issues-count: (+ (get issues-count performance) u1)
    }))

    ;; If critical issue, automatically set status to down
    (if (is-eq severity "critical")
      (try! (update-equipment-status equipment-id "down"))
      true
    )

    (ok issue-id)
  )
)

;; Resolve an equipment issue
(define-public (resolve-issue
    (equipment-id uint)
    (issue-id uint)
    (resolution-description (optional (string-ascii 500)))
  )
  (let (
    (issue (unwrap! (map-get? equipment-issues (tuple (equipment-id equipment-id) (issue-id issue-id))) (err u404)))
  )
    ;; Check if issue is not already resolved
    (asserts! (not (get resolved issue)) (err u400))

    ;; Update issue to resolved
    (map-set equipment-issues (tuple (equipment-id equipment-id) (issue-id issue-id)) (merge issue {
      resolved: true,
      resolution-timestamp: block-height,
      resolution-description: resolution-description
    }))

    (ok true)
  )
)

;; Get equipment performance data
(define-read-only (get-equipment-performance (equipment-id uint))
  (map-get? equipment-performance equipment-id)
)

;; Get equipment issue details
(define-read-only (get-issue-details (equipment-id uint) (issue-id uint))
  (map-get? equipment-issues (tuple (equipment-id equipment-id) (issue-id issue-id)))
)

;; Calculate equipment reliability (uptime percentage)
(define-read-only (calculate-reliability (equipment-id uint))
  (let (
    (performance (unwrap-panic (map-get? equipment-performance equipment-id)))
    (total-time (+ (get total-uptime performance) (get total-downtime performance)))
  )
    (if (> total-time u0)
      (/ (* (get total-uptime performance) u10000) total-time)  ;; Returns percentage with 2 decimal places (multiply by 10000)
      u10000  ;; If no data yet, return 100.00%
    )
  )
)
