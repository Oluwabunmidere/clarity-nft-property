;;;; Contract File Name: property-tokenization.clar
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
