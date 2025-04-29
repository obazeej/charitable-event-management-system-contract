# Charitable Event Management System - Smart Contract

## Overview

This Clarity smart contract provides a robust platform for managing charitable events and donations on the Stacks blockchain. The contract enables secure donation collection, cause allocation, and transparent withdrawal processes with built-in security features and administrative controls.

## Key Features

### 🔒 Secure Donation Management
- Collect and track donations from multiple users
- Enforce minimum and maximum contribution limits
- Prevent unauthorized withdrawals and transfers

### 🎯 Cause Allocation System
- Register and manage multiple charitable causes
- Allocate funds to specific causes with configurable proportions
- Add, update, and remove causes through secure admin functions

### 💰 Withdrawal Controls
- Time-based cooldown period (24 hours) between withdrawals
- Authorization checks to prevent unauthorized withdrawals
- Transparent withdrawal tracking

### 👮 Administrative Functions
- Emergency halt capabilities
- Contract suspension toggles
- Flexible management controls with ownership transfer

### 📊 Transparency Features
- Event logging for all major actions
- Donation and withdrawal history tracking
- Public read-only functions for stats and verification

## Technical Details

### Constants

| Constant | Description |
|----------|-------------|
| `ERR_UNAUTHORIZED` | Error code for unauthorized access attempts |
| `ERR_INVALID_AMOUNT` | Error code for invalid amount inputs |
| `ERR_INSUFFICIENT_FUNDS` | Error code for insufficient balance operations |
| `ERR_CAUSE_NOT_FOUND` | Error code when referenced cause doesn't exist |
| `ERR_CAUSE_EXISTS` | Error code when attempting to add duplicate cause |
| `ERR_NOT_CONFIRMED` | Error code for unconfirmed critical operations |
| `ERR_UNCHANGED_STATE` | Error code when no state change would occur |
| `withdrawal-cooldown` | Cooldown period (24 hours in seconds) between withdrawals |

### Data Variables

| Variable | Description |
|----------|-------------|
| `total-donations` | Running sum of all donations received |
| `event-manager` | Principal (address) of the contract administrator |
| `min-contribution` | Minimum acceptable donation amount |
| `max-contribution` | Maximum acceptable donation amount |
| `is-suspended` | Contract operation status flag |

### Maps

| Map | Description |
|-----|-------------|
| `contributions` | Tracks total contributions by user address |
| `causes` | Stores registered causes and their allocation percentages |
| `last-contribution` | Records timestamps of user's most recent actions |

## Functions

### Public Functions

#### Donation Management
- `contribute`: Submit a donation to the contract
- `withdraw-contribution`: Withdraw funds with cooldown enforcement
- `set-contribution-limits`: Update minimum and maximum donation thresholds

#### Cause Management
- `add-cause`: Register a new charitable cause
- `update-cause-allocation`: Modify a cause's allocation percentage
- `remove-cause`: Remove a cause from the registry
- `confirm-remove-cause`: Two-step confirmation for cause removal

#### Admin Functions
- `set-manager`: Transfer administrative privileges
- `set-suspended`: Toggle contract operation status
- `emergency-halt`: Immediately suspend all contract operations
- `log-action`: Record administrative actions for transparency

### Read-Only Functions

- `get-user-contribution`: View a user's total contributions
- `get-total-donations`: Get total donation volume
- `check-is-suspended`: Check if contract operations are suspended
- `get-cause-allocation`: View a cause's allocation percentage
- `get-manager`: Identify the current contract administrator
- `get-user-history`: Retrieve a user's donation and withdrawal history

## Usage Examples

### Making a Donation
```clarity
;; Donate 100 STX to the charitable event
(contract-call? .charitable-event-contract contribute u100)
```

### Adding a Charitable Cause
```clarity
;; Add a new cause with 25% allocation
(contract-call? .charitable-event-contract add-cause 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM u25)
```

### Withdrawing Funds
```clarity
;; Withdraw 50 STX from donations
(contract-call? .charitable-event-contract withdraw-contribution u50)
```

### Setting Contribution Limits
```clarity
;; Set min donation to 5 STX and max to 1000 STX
(contract-call? .charitable-event-contract set-contribution-limits u5 u1000)
```