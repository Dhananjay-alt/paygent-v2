# Paygent v2

> Paygent v2 uses ENS as a live, on-chain configuration layer that controls how subscription payments execute.

Paygent v2 is an on-chain subscription payment protocol that turns **idle subscription funds into executable, automated payments** using ENS-based configuration and Chainlink Automation.

In other words, **Paygent v2 makes idle subscription funds alive** — funds are not just locked, they are actively scheduled, verified, and executed on-chain under strict protocol rules.

---

## Problem

Traditional subscription systems lock capital until payment time.

- Funds sit idle and opaque
- Execution relies on trusted off-chain schedulers
- Payment logic is hardcoded and inflexible

Capital is locked, but not alive.

---

## Solution

Paygent v2 separates **custody**, **configuration**, and **execution**:

- Funds are held safely in user vaults
- Payment logic is defined externally via ENS
- Execution is triggered autonomously via on-chain automation

Funds only become executable when explicit protocol conditions are met.  
Automation cannot bypass safety checks.

---

## Architecture Overview

- **User Vault**  
  Holds deposited funds and enforces accounting rules.

- **ENS Strategy (Configuration Layer)**  
  Stores payment parameters such as merchant, amount, and interval.

- **Executor (Liquidity Layer)**  
  Holds explicitly deployed liquidity for execution.

- **Automation (Execution Trigger)**  
  Calls into the protocol only when conditions are satisfied.

This separation ensures flexibility without sacrificing safety.

---

## ENS Integration (Prize Eligibility)

Paygent v2 uses Ethereum Name Service (ENS) as a **core protocol dependency**, not a naming convenience.

Payment strategies are stored as ENS text records and resolved on-chain at execution time:

- `merchant` — recipient address  
- `paymentAmount` — amount per interval  
- `paymentInterval` — execution frequency  

### Why ENS Matters

ENS acts as **protocol state**:

- Payment logic lives in ENS, not immutable bytecode
- Strategies can be updated without redeploying contracts
- Automation always executes against the latest ENS configuration
- All changes are transparent and on-chain

### Eligibility Statement

Paygent v2 is eligible for the ENS track because **the protocol cannot function without ENS**.

Without ENS:
- payment strategies cannot be defined
- execution parameters cannot be updated
- automation has no source of truth

ENS directly controls how and when funds become executable.

---

## Automation

Paygent v2 integrates with **Chainlink Automation** for autonomous execution.

- `checkUpkeep()` verifies payment conditions on-chain
- `performUpkeep()` executes payments through the manager
- Execution is permissionless and fully verifiable

Automation has been **successfully verified live on Sepolia**, with Chainlink nodes executing payments and spending LINK for gas.

---

## On-chain Verification (Sepolia)

The end-to-end flow can be verified via:

- Chainlink Automation history (`Perform Upkeep`)
- `PaymentExecuted` events emitted by the protocol
- ERC20 `Transfer` events to the merchant address

Relevant contract addresses are documented in `docs/sepolia-addresses.txt`.

---

## Safety Guarantees

- Automation cannot execute early
- Liquidity must be explicitly deployed before execution
- Vault funds and executable liquidity are strictly separated
- Failed conditions halt execution safely

These guarantees were observed and validated during live testing.

---

## Status

- ✅ ENS-configured subscription strategies
- ✅ Vault and executor separation enforced
- ✅ Chainlink Automation live
- ✅ End-to-end execution verified on-chain

---

## Future Work

- Uniswap-based liquidity executor
- Batched multi-user automation
- Mainnet deployment

---

## Summary

Paygent v2 demonstrates how ENS and automation can be combined to create **safe, flexible, and autonomous subscription payments** — where funds are not merely locked, but **alive and executable on-chain**.
