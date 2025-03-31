# Resource Registry

A decentralized system for managing and tracking resource custodianship on the blockchain.

## Overview

Resource Registry provides a transparent and secure way to register, transfer, and manage digital resources. It enables entities to claim custodianship of resources identified by unique identifiers and transfer that custodianship to other entities when needed.

## Features

- **Resource Registration**: Register unique resources with cryptographic identifiers
- **Custodianship Tracking**: Track which entity is the current custodian of each resource
- **Secure Transfers**: Transfer resource custodianship between entities
- **Resource Management**: Deregister resources when they're no longer needed
- **Entity Tracking**: Monitor how many resources each entity manages

## Functions

- `register-resource`: Claim custodianship of a new resource
- `is-resource-registered`: Check if a resource is already registered
- `get-resource-custodian`: Find out who is the current custodian of a resource
- `transfer-resource`: Transfer custodianship to another entity
- `deregister-resource`: Remove a resource from the registry
- `get-entity-resource-count`: Count how many resources an entity manages
- `entity-has-resources`: Check if an entity manages any resources

## Getting Started

1. Deploy the contract to your blockchain
2. Register resources using their unique identifiers
3. Transfer custodianship as needed
4. Monitor resource management across entities

## Security

The system ensures that only the current custodian of a resource can transfer or deregister it, maintaining secure chain of custody.