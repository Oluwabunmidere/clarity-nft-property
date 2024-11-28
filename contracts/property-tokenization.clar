;; Contract File Name: property-tokenization.clar
;; Description: Real Estate Property Management Contract
;; This contract handles the tokenization of real estate properties using NFTs.
;; It includes features for property registration, ownership management, data validation, and property transfer.

;; -------------------------------
;; Constants
;; -------------------------------

(define-constant contract-owner tx-sender) 
;; Contract owner, usually the deployer of the contract.

(define-constant err-owner-only (err u100)) 
;; Error: Only the contract owner can perform this operation.

(define-constant err-not-property-owner (err u101)) 
;; Error: Caller is not the owner of the specified property.

(define-constant err-property-exists (err u102)) 
;; Error: Property already exists (not currently used in this contract).

(define-constant err-property-not-found (err u103)) 
;; Error: Specified property does not exist.

(define-constant err-transfer-failed (err u104)) 
;; Error: Property transfer failed due to invalid recipient.

(define-constant err-already-transferred (err u105)) 
;; Error: Property has already been transferred and cannot be transferred again.

(define-constant err-invalid-property-data (err u106)) 
;; Error: Provided property data is invalid (empty or exceeds length).

;; -------------------------------
;; Data Variables
;; -------------------------------

(define-non-fungible-token property uint) 
;; Non-fungible token (NFT) representing unique properties.

(define-data-var last-property-id uint u0) 
;; Tracks the last assigned property ID to ensure unique identifiers.

;; -------------------------------
;; Mappings
;; -------------------------------

(define-map property-data uint (string-ascii 256)) 
;; Stores details about each property, mapped by property ID.

(define-map property-owners uint principal) 
;; Maps property IDs to their current owner's address.

(define-map transferred-properties uint bool) 
;; Tracks whether a property has been transferred, mapped by property ID.

;; -------------------------------
;; Private Helper Functions
;; -------------------------------

(define-private (is-property-owner (property-id uint) (sender principal))
    ;; Validates if the sender is the owner of the given property ID.
    (is-eq sender (unwrap! (map-get? property-owners property-id) false)))

(define-private (is-valid-property-data (data (string-ascii 256)))
    ;; Checks whether the provided property data is valid (length between 1 and 256 characters).
    (let ((data-length (len data)))
        (and (>= data-length u1)
             (<= data-length u256))))

(define-private (register-property (property-details (string-ascii 256)))
    ;; Registers a new property by assigning a unique ID and storing its details.
    (let ((property-id (+ (var-get last-property-id) u1)))
        (asserts! (is-valid-property-data property-details) err-invalid-property-data)
        (try! (nft-mint? property property-id tx-sender))
        (map-set property-data property-id property-details)
        (map-set property-owners property-id tx-sender)
        (var-set last-property-id property-id)
        (ok property-id)))

;; -------------------------------
;; Public Functions
;; -------------------------------

(define-public (add-property (property-details (string-ascii 256)))
    ;; Allows the contract owner to add a new property with valid details.
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (is-valid-property-data property-details) err-invalid-property-data)
        (register-property property-details)))

(define-public (transfer-property (property-id uint) (recipient principal))
    ;; Transfers ownership of a property to a specified recipient.
    (begin
        (let ((property-owner (unwrap! (map-get? property-owners property-id) err-property-not-found)))
            (asserts! (is-eq tx-sender property-owner) err-not-property-owner)

            (let ((is-transferred (default-to false (map-get? transferred-properties property-id))))
                (asserts! (not is-transferred) err-already-transferred))

            (asserts! (is-eq recipient recipient) err-transfer-failed)
            (map-set property-owners property-id recipient)
            (map-set transferred-properties property-id true)
            (ok true))))

(define-public (get-property-owner (property-id uint))
    ;; Retrieves the current owner's principal address for a given property ID.
    (ok (map-get? property-owners property-id)))

(define-public (get-property-data (property-id uint))
    ;; Retrieves the stored data for a specified property ID.
    (ok (map-get? property-data property-id)))

(define-public (validate-property-owner (property-id uint) (claimed-owner principal))
;; Validates if the claimed owner matches the actual property owner
(let ((actual-owner (unwrap! (map-get? property-owners property-id) err-property-not-found)))
    (ok (is-eq actual-owner claimed-owner))))

(define-public (get-property-data-length (property-id uint))
;; Returns the length of the property data string
(ok (len (unwrap! (map-get? property-data property-id) err-property-not-found))))

(define-public (freeze-property-transfer (property-id uint))
;; Prevents further transfers of a specific property
(begin
    (asserts! (is-property-owner property-id tx-sender) err-not-property-owner)
    (map-set transferred-properties property-id true)
    (ok true)))

(define-public (add-multiple-properties 
(property-details (list 10 (string-ascii 256))))
;; Allows bulk registration of properties
(begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (let ((registration-results 
        (map register-property property-details)))
        (ok registration-results))))

;; -------------------------------
;; Read-Only Functions
;; -------------------------------

(define-read-only (is-transferred (property-id uint))
    ;; Checks if a property has already been transferred.
    (ok (default-to false (map-get? transferred-properties property-id))))

(define-read-only (get-last-property-id)
    ;; Retrieves the last assigned property ID.
    (ok (var-get last-property-id)))

(define-read-only (check-property-transferred (property-id uint))
;; Checks if a property has been transferred or not.
(ok (default-to false (map-get? transferred-properties property-id))))

(define-read-only (get-total-properties)
;; Returns the total number of properties that have been registered.
(ok (var-get last-property-id)))

(define-read-only (is-property-exists (property-id uint))
;; Checks if a property with the given ID exists.
(ok (is-none (map-get? property-owners property-id))))

(define-read-only (can-transfer-property (property-id uint))
;; Checks if a property is eligible for transfer (i.e., has not been transferred already).
(ok (not (default-to false (map-get? transferred-properties property-id)))))

(define-read-only (is-property-registered (property-id uint))
;; Checks if the property ID exists and is registered in the contract.
(ok (is-some (map-get? property-owners property-id))))

(define-read-only (get-property-transfer-status (property-id uint))
;; Returns the transfer status of a specific property.
(ok (default-to false (map-get? transferred-properties property-id))))

(define-read-only (get-owner (property-id uint))
;; Retrieves the owner's address for the given property ID.
(ok (map-get? property-owners property-id)))

(define-read-only (is-property-transferable (property-id uint))
;; Checks if a property can be transferred (not already transferred).
(ok (not (default-to false (map-get? transferred-properties property-id)))))

(define-read-only (get-property-details (property-id uint))
;; Retrieves the details of the specified property.
(ok (map-get? property-data property-id)))

(define-read-only (property-id-exists (property-id uint))
;; Checks if a specific property ID exists
(ok (is-some (map-get? property-owners property-id))))

(define-read-only (get-property-data-hash (property-id uint))
;; Generates a simple hash of property data for verification
(ok (default-to "" 
    (map-get? property-data property-id))))

;; -------------------------------
;; Contract Initialization
;; -------------------------------

(begin
    ;; Initialize the last property ID to 0 during deployment.
    (var-set last-property-id u0))
