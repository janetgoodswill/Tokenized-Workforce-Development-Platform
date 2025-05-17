;; Training Recommendation Contract
;; Matches workers with education opportunities

(define-data-var admin principal tx-sender)

;; Data structure for training programs
(define-map training-programs
  { program-id: uint }
  {
    name: (string-utf8 100),
    description: (string-utf8 500),
    provider: (string-utf8 100),
    target-skills: (list 10 uint),
    duration: uint,
    difficulty: uint
  }
)

;; Data structure for worker recommendations
(define-map worker-recommendations
  { worker: principal }
  {
    recommended-programs: (list 20 uint),
    last-updated: uint
  }
)

;; Counter for program IDs
(define-data-var program-id-counter uint u0)

;; Public function to add a training program
(define-public (add-training-program
    (name (string-utf8 100))
    (description (string-utf8 500))
    (provider (string-utf8 100))
    (target-skills (list 10 uint))
    (duration uint)
    (difficulty uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u100))
    (let ((new-id (+ (var-get program-id-counter) u1)))
      (var-set program-id-counter new-id)
      (map-set training-programs
        { program-id: new-id }
        {
          name: name,
          description: description,
          provider: provider,
          target-skills: target-skills,
          duration: duration,
          difficulty: difficulty
        }
      )
      (ok new-id)
    )
  )
)

;; Public function to recommend training programs to a worker
(define-public (recommend-programs
    (worker principal)
    (program-ids (list 20 uint)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u100))
    (map-set worker-recommendations
      { worker: worker }
      {
        recommended-programs: program-ids,
        last-updated: block-height
      }
    )
    (ok true)
  )
)

;; Read-only function to get a worker's recommendations
(define-read-only (get-worker-recommendations (worker principal))
  (map-get? worker-recommendations { worker: worker })
)

;; Read-only function to get training program details
(define-read-only (get-training-program (program-id uint))
  (map-get? training-programs { program-id: program-id })
)

;; Function to transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u100))
    (var-set admin new-admin)
    (ok true)
  )
)
