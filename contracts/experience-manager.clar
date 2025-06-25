;; Experience Manager Verification Contract
;; Manages and verifies customer experience managers

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_ALREADY_VERIFIED (err u101))
(define-constant ERR_NOT_FOUND (err u102))

;; Data structures
(define-map experience-managers
  principal
  {
    verified: bool,
    reputation-score: uint,
    total-customers: uint,
    registration-block: uint
  }
)

(define-map manager-credentials
  principal
  {
    certification-level: (string-ascii 20),
    specialization: (string-ascii 50),
    years-experience: uint
  }
)

;; Public functions
(define-public (register-manager (certification (string-ascii 20)) (specialization (string-ascii 50)) (years uint))
  (let ((manager tx-sender))
    (asserts! (is-none (map-get? experience-managers manager)) ERR_ALREADY_VERIFIED)
    (map-set experience-managers manager {
      verified: false,
      reputation-score: u0,
      total-customers: u0,
      registration-block: block-height
    })
    (map-set manager-credentials manager {
      certification-level: certification,
      specialization: specialization,
      years-experience: years
    })
    (ok true)
  )
)

(define-public (verify-manager (manager principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (is-some (map-get? experience-managers manager)) ERR_NOT_FOUND)
    (map-set experience-managers manager
      (merge (unwrap-panic (map-get? experience-managers manager)) {verified: true}))
    (ok true)
  )
)

(define-public (update-reputation (manager principal) (score uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (is-some (map-get? experience-managers manager)) ERR_NOT_FOUND)
    (map-set experience-managers manager
      (merge (unwrap-panic (map-get? experience-managers manager)) {reputation-score: score}))
    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-manager-info (manager principal))
  (map-get? experience-managers manager)
)

(define-read-only (get-manager-credentials (manager principal))
  (map-get? manager-credentials manager)
)

(define-read-only (is-verified-manager (manager principal))
  (match (map-get? experience-managers manager)
    manager-data (get verified manager-data)
    false
  )
)
