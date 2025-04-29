;; constants
(define-constant ERR_UNAUTHORIZED (err u1))
(define-constant ERR_INVALID_AMOUNT (err u2))
(define-constant ERR_INSUFFICIENT_FUNDS (err u3))
(define-constant ERR_CAUSE_NOT_FOUND (err u4))
(define-constant ERR_CAUSE_EXISTS (err u5))
(define-constant ERR_NOT_CONFIRMED (err u8))
(define-constant ERR_UNCHANGED_STATE (err u9))
(define-constant withdrawal-cooldown u86400) ;; 24 hours in seconds

;; data maps and vars
(define-data-var total-donations uint u0)
(define-data-var event-manager principal tx-sender)
(define-data-var min-contribution uint u1)
(define-data-var max-contribution uint u1000000000)
(define-data-var is-suspended bool false)

;; Maps
(define-map contributions principal uint)
(define-map causes principal uint)
(define-map last-contribution principal uint)

;; private functions
(define-private (get-contribution (user principal))
  (default-to u0 (map-get? contributions user))
)

(define-private (update-contribution (amount uint))
  (let ((current-contribution (get-contribution tx-sender)))
    (map-set contributions tx-sender (+ current-contribution amount))
    (var-set total-donations (+ (var-get total-donations) amount))
  )
)

;; public functions
(define-public (contribute (amount uint))
  (if (and (not (var-get is-suspended))
           (>= amount (var-get min-contribution))
           (<= amount (var-get max-contribution)))
    (begin
      (update-contribution amount)
      (print {event: "donation", sender: tx-sender, amount: amount})
      (ok amount)
    )
    (err u100) ;; Error: Invalid donation amount or contract suspended
  )
)

(define-public (add-cause (cause principal) (allocation uint))
  (if (and (is-eq tx-sender (var-get event-manager))
           (is-none (map-get? causes cause))
           (> allocation u0))
    (begin
      (map-set causes cause allocation)
      (print {event: "cause-added", cause: cause, allocation: allocation})
      (ok (tuple (cause cause) (allocation allocation)))
    )
    (err u101) ;; Error: Unauthorized or invalid input
  )
)

(define-public (withdraw-contribution (amount uint))
  (let (
    (current-contribution (get-contribution tx-sender))
    (last-contribution-time (default-to u0 (map-get? last-contribution tx-sender)))
    (current-time (unwrap-panic (get-block-info? time u0)))
  )
    (if (and (not (var-get is-suspended))
             (> current-contribution u0)
             (>= current-contribution amount)
             (>= (- current-time last-contribution-time) withdrawal-cooldown))
      (begin
        (map-set contributions tx-sender (- current-contribution amount))
        (var-set total-donations (- (var-get total-donations) amount))
        (map-set last-contribution tx-sender current-time)
        (print {event: "withdrawal", recipient: tx-sender, amount: amount})
        (as-contract (stx-transfer? amount tx-sender 'ST000000000000000000002AMW42H))
      )
      (err u102) ;; Error: Invalid withdrawal or cooldown period not met
    )
  )
)

(define-public (set-manager (new-manager principal))
  (let ((current-manager (var-get event-manager)))
    (begin
      (asserts! (is-eq tx-sender current-manager) ERR_UNAUTHORIZED)
      (asserts! (not (is-eq new-manager current-manager)) (err u6)) ;; New error for unchanged manager
      (var-set event-manager new-manager)
      (ok new-manager)
    )
  )
)

(define-public (set-contribution-limits (new-min uint) (new-max uint))
  (if (and (is-eq tx-sender (var-get event-manager)) (< new-min new-max))
    (begin
      (var-set min-contribution new-min)
      (var-set max-contribution new-max)
      (print {event: "donation-limits-updated", min: new-min, max: new-max})
      (ok true)
    )
    (err u104) ;; Error: Unauthorized or invalid limits
  )
)

(define-public (set-suspended (new-suspended-state bool))
  (let ((current-suspended-state (var-get is-suspended)))
    (begin
      (asserts! (is-eq tx-sender (var-get event-manager)) ERR_UNAUTHORIZED)
      (asserts! (not (is-eq new-suspended-state current-suspended-state)) ERR_UNCHANGED_STATE)
      (var-set is-suspended new-suspended-state)
      (print {event: "contract-suspend-changed", suspended: new-suspended-state})
      (ok new-suspended-state)
    )
  )
)

(define-public (update-cause-allocation (cause principal) (new-allocation uint))
  (begin
    (asserts! (is-eq tx-sender (var-get event-manager)) ERR_UNAUTHORIZED)
    (asserts! (> new-allocation u0) ERR_INVALID_AMOUNT)
    (asserts! (is-some (map-get? causes cause)) ERR_CAUSE_NOT_FOUND)
    (ok (map-set causes cause new-allocation))
  )
)

(define-public (remove-cause (cause principal))
  (begin
    (asserts! (is-eq tx-sender (var-get event-manager)) ERR_UNAUTHORIZED)
    (asserts! (is-some (map-get? causes cause)) ERR_CAUSE_NOT_FOUND)
    (map-delete causes cause)
    (ok true)
  )
)

(define-public (confirm-remove-cause (cause principal) (confirm bool))
  (begin
    (asserts! (is-eq tx-sender (var-get event-manager)) ERR_UNAUTHORIZED)
    (asserts! confirm ERR_NOT_CONFIRMED)
    (asserts! (is-some (map-get? causes cause)) ERR_CAUSE_NOT_FOUND)
    (map-delete causes cause)
    (print {event: "cause-removed", cause: cause})
    (ok true)
  )
)

(define-public (emergency-halt)
  (if (is-eq tx-sender (var-get event-manager))
    (begin
      (var-set is-suspended true)
      (print {event: "emergency-halt", admin: tx-sender})
      (ok true)
    )
    (err u105) ;; Error: Unauthorized
  )
)

(define-public (log-action (action-type (string-ascii 32)) (actor principal))
  (let ((current-time (unwrap-panic (get-block-info? time u0))))
    (ok true)
  )
)

;; Read-Only Functions
(define-read-only (get-user-contribution (user principal))
  (default-to u0 (map-get? contributions user))
)

(define-read-only (get-total-donations)
  (ok (var-get total-donations))
)

(define-read-only (check-is-suspended)
  (ok (var-get is-suspended))
)

(define-read-only (get-cause-allocation (cause principal))
  (ok (default-to u0 (map-get? causes cause)))
)

(define-read-only (get-manager)
  (ok (var-get event-manager))
)

(define-read-only (get-user-history (user principal))
  ;; Return donation and withdrawal records for a user
  (ok (tuple (donations (map-get? contributions user)) (withdrawals (map-get? last-contribution user))))
)
