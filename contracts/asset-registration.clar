;; Asset Registration Contract
;; Records details of industrial equipment as non-fungible tokens

(define-non-fungible-token equipment uint)

;; Data structure for equipment details
(define-map equipment-details uint
  {
    name: (string-ascii 100),
    manufacturer: (string-ascii 100),
    model: (string-ascii 100),
    serial-number: (string-ascii 100),
    manufacture-date: uint,
    installation-date: uint,
    location: (string-ascii 100),
    owner: principal
  }
)

;; Counter for equipment IDs
(define-data-var equipment-id-counter uint u1)

;; Register new equipment
(define-public (register-equipment
    (name (string-ascii 100))
    (manufacturer (string-ascii 100))
    (model (string-ascii 100))
    (serial-number (string-ascii 100))
    (manufacture-date uint)
    (installation-date uint)
    (location (string-ascii 100))
  )
  (let ((new-id (var-get equipment-id-counter)))
    ;; Mint new equipment NFT
    (try! (nft-mint? equipment new-id tx-sender))

    ;; Store equipment details
    (map-set equipment-details new-id {
      name: name,
      manufacturer: manufacturer,
      model: model,
      serial-number: serial-number,
      manufacture-date: manufacture-date,
      installation-date: installation-date,
      location: location,
      owner: tx-sender
    })

    ;; Increment the counter
    (var-set equipment-id-counter (+ new-id u1))

    ;; Return the new equipment ID
    (ok new-id)
  )
)

;; Get equipment details
(define-read-only (get-equipment-details (id uint))
  (map-get? equipment-details id)
)

;; Transfer equipment ownership
(define-public (transfer-equipment (id uint) (recipient principal))
  (begin
    ;; Check if sender is the owner
    (asserts! (is-eq tx-sender (unwrap! (nft-get-owner? equipment id) (err u403))) (err u403))

    ;; Transfer the NFT
    (try! (nft-transfer? equipment id tx-sender recipient))

    ;; Update the owner in equipment details
    (let ((current-details (unwrap! (map-get? equipment-details id) (err u404))))
      (map-set equipment-details id (merge current-details {owner: recipient}))
    )

    (ok true)
  )
)

;; Update equipment location
(define-public (update-equipment-location (id uint) (new-location (string-ascii 100)))
  (begin
    ;; Check if sender is the owner
    (asserts! (is-eq tx-sender (unwrap! (nft-get-owner? equipment id) (err u403))) (err u403))

    ;; Update the location in equipment details
    (let ((current-details (unwrap! (map-get? equipment-details id) (err u404))))
      (map-set equipment-details id (merge current-details {location: new-location}))
    )

    (ok true)
  )
)
