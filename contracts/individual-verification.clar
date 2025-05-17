;; Individual Verification Contract
;; This contract validates worker identities and stores verification status

(define-data-var admin principal tx-sender)

;; Data structure for verified individuals
(define-map verified-individuals
  { id: principal }
  {
    name: (string-utf8 100),
    verified: bool,
    verification-date: uint,
    verification-expiry: uint
  }
)

;; Public function to verify an individual
(define-public (verify-individual
    (id principal)
    (name (string-utf8 100))
    (expiry-blocks uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u100))
    (map-set verified-individuals
      { id: id }
      {
        name: name,
        verified: true,
        verification-date: block-height,
        verification-expiry: (+ block-height expiry-blocks)
      }
    )
    (ok true)
  )
)

;; Public function to check if an individual is verified
(define-read-only (is-verified (id principal))
  (let ((individual (unwrap! (map-get? verified-individuals { id: id }) (ok false))))
    (if (and
          (get verified individual)
          (< block-height (get verification-expiry individual)))
      (ok true)
      (ok false)
    )
  )
)

;; Public function to revoke verification
(define-public (revoke-verification (id principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u100))
    (map-delete verified-individuals { id: id })
    (ok true)
  )
)

;; Function to transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u100))
    (var-set admin new-admin)
    (ok true)
  )
)
