;; ResourceRegistry - a decentralized resource management system
;; Constants for error codes
(define-constant ERR-ALREADY-REGISTERED u100)
(define-constant ERR-NOT-FOUND u101)
(define-constant ERR-INVALID-RESOURCE u102)
(define-constant ERR-NOT-CUSTODIAN u103)

;; Define a map to store resource custodianship information
(define-map resource-catalog
  {resource-id: (buff 32)}  ;; Key: Resource identifier
  {custodian: principal})   ;; Value: Resource custodian principal

;; Define a map to track resources managed by each entity
(define-map entity-resources
  {entity: principal}
  {resource-count: uint})

;; Public function to register a new resource
(define-public (register-resource (resource-id (buff 32)))
  (let ((entity tx-sender))
    (if (<= (len resource-id) u32)
        (if (is-some (map-get? resource-catalog {resource-id: resource-id}))
            (err ERR-ALREADY-REGISTERED)
            (begin
              (map-set resource-catalog {resource-id: resource-id} {custodian: entity})
              (map-set entity-resources {entity: entity} 
                {resource-count: (+ u1 (default-to u0 (get resource-count (map-get? entity-resources {entity: entity}))))})
              (ok true)))
        (err ERR-INVALID-RESOURCE))))

;; Public function to check if a resource is registered
(define-public (is-resource-registered (resource-id (buff 32)))
  (ok (is-some (map-get? resource-catalog {resource-id: resource-id}))))

;; Public function to get the custodian of a registered resource
(define-public (get-resource-custodian (resource-id (buff 32)))
  (match (map-get? resource-catalog {resource-id: resource-id})
    registration (ok (get custodian registration))
    (err ERR-NOT-FOUND)))

;; Public function to transfer resource custodianship
(define-public (transfer-resource (resource-id (buff 32)) (new-custodian principal))
  (let 
    (
      (entity tx-sender)
      (current-custodian-resources (get resource-count (default-to {resource-count: u0} (map-get? entity-resources {entity: entity}))))
    )
    (if (and 
          (<= (len resource-id) u32) 
          (is-some (map-get? resource-catalog {resource-id: resource-id}))
          (not (is-eq new-custodian entity))
        )
        (match (map-get? resource-catalog {resource-id: resource-id})
          registration 
            (if (is-eq (get custodian registration) entity)
                (begin
                  (map-set resource-catalog {resource-id: resource-id} {custodian: new-custodian})
                  (map-set entity-resources {entity: entity} 
                    {resource-count: (- current-custodian-resources u1)})
                  (map-set entity-resources {entity: new-custodian} 
                    {resource-count: (+ u1 (default-to u0 (get resource-count (map-get? entity-resources {entity: new-custodian}))))})
                  (ok true))
                (err ERR-NOT-CUSTODIAN))
          (err ERR-NOT-FOUND))
        (err ERR-INVALID-RESOURCE))))

;; Public function to deregister a resource
(define-public (deregister-resource (resource-id (buff 32)))
  (let ((entity tx-sender))
    (if (<= (len resource-id) u32)
        (match (map-get? resource-catalog {resource-id: resource-id})
          registration 
            (if (is-eq (get custodian registration) entity)
                (begin
                  (map-delete resource-catalog {resource-id: resource-id})
                  (map-set entity-resources {entity: entity} 
                    {resource-count: (- (default-to u0 (get resource-count (map-get? entity-resources {entity: entity}))) u1)})
                  (ok true))
                (err ERR-NOT-CUSTODIAN))
          (err ERR-NOT-FOUND))
        (err ERR-INVALID-RESOURCE))))

;; Public function to get the number of resources managed by an entity
(define-public (get-entity-resource-count (entity principal))
  (ok (default-to u0 (get resource-count (map-get? entity-resources {entity: entity})))))

;; Public function to check if an entity manages any resources
(define-public (entity-has-resources (entity principal))
  (ok (> (default-to u0 (get resource-count (map-get? entity-resources {entity: entity}))) u0)))

