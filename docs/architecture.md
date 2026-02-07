# Architecture Overview

Paygent v2 is designed around a strict separation of concerns to enable **safe, flexible, and autonomous subscription payments**.

The protocol separates **custody**, **configuration**, **liquidity**, and **execution** into independent components.  
This prevents automation from bypassing safety rules while allowing payment logic to evolve over time.

---

## High-Level Architecture

Paygent v2 consists of four core layers:

1. User Vault (Custody)
2. ENS Strategy (Configuration)
3. Executor (Liquidity)
4. Automation (Execution Trigger)

Each layer has a single responsibility and cannot override the others.

---

## 1. User Vault (Custody Layer)

The User Vault is managed by the `PaymentManager`.

Responsibilities:
- Hold user-deposited funds
- Track balances and accounting
- Enforce execution state and timing rules

Key properties:
- Funds in the vault **cannot be spent directly**
- Automation has no access to vault balances
- All movements are explicitly authorized by protocol logic

This ensures user funds are never silently drained by automation.

---

## 2. ENS Strategy (Configuration Layer)

Payment strategies are defined using **Ethereum Name Service (ENS)**.

Instead of hardcoding payment logic, Paygent v2 resolves strategy data from ENS text records at execution time.

Strategy fields include:
- `merchant` — payment recipient
- `paymentAmount` — amount per interval
- `paymentInterval` — execution frequency

Why ENS is used:
- Strategies are upgradeable without redeployment
- Configuration is on-chain and transparent
- Automation always executes against the latest configuration

ENS acts as **live protocol state**, not just a naming system.

---

## 3. Executor (Liquidity Layer)

The Executor is responsible for holding **explicitly deployed liquidity**.

Responsibilities:
- Receive liquidity deployed from the vault
- Track per-user executable balances
- Release funds only when instructed by the manager

Key invariant:
- **Vault funds ≠ executable liquidity**

Liquidity must be deliberately deployed from the vault into the executor before any payment can occur.

This design ensures:
- automation cannot pull funds prematurely
- execution fails safely if liquidity is missing

---

## 4. Automation (Execution Trigger)

Paygent v2 integrates with **Chainlink Automation**.

The automation contract:
- Checks whether a payment is due
- Calls into the manager to execute payment
- Has no authority to change configuration or move funds directly

Automation can:
- trigger execution  
Automation cannot:
- modify ENS strategies
- bypass timing rules
- withdraw vault funds directly

This makes automation **permissionless but powerless**.

---

## Execution Flow

A successful payment follows this sequence:

1. ENS strategy is resolved on-chain
2. Automation verifies payment conditions
3. Manager instructs executor to withdraw liquidity
4. Merchant is paid
5. Next payment time is scheduled

If any condition fails (time, liquidity, execution mode), the transaction reverts safely.

---

## Safety Guarantees

Paygent v2 enforces the following guarantees:

- Automation cannot execute early
- Liquidity must be explicitly deployed
- Configuration changes are transparent
- Execution is deterministic and verifiable
- Funds move only through protocol-defined paths

These guarantees were validated during live testing on Sepolia.

---

## Design Rationale

This architecture intentionally avoids:
- trusted off-chain schedulers
- monolithic contracts
- implicit fund access

Instead, it favors:
- explicit state transitions
- composable execution layers
- on-chain sources of truth

The result is a protocol where subscription payments are **autonomous, but never unsafe**.

---

## Extensibility

Because execution and liquidity are abstracted, new executors can be added without modifying core logic.

Examples:
- Uniswap-based liquidity executor
- Yield-generating strategies
- Batched multi-user execution

The core manager and ENS strategy layer remain unchanged.

---

## Summary

Paygent v2 demonstrates how ENS and on-chain automation can be combined to create **safe, upgradeable, and autonomous subscription payments** — where funds are not merely locked, but become executable only under explicit protocol control.
