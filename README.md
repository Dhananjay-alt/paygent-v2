# Paygent v2 — Agentic Liquidity & Payment Orchestrator  

Paygent v2 is an **agent-driven payment orchestration system** that enables **batch-based, strategy-controlled payments** using ENS as a configuration layer and a Yellow-style execution abstraction for scalable settlement.

The system separates **payment intent execution (off-chain + accounting)** from **final settlement (on-chain)**, enabling gas-efficient batching and future-proof extensibility for ZK proofs and rollup-style settlement.

---

## Core Idea  

Traditional on-chain payments execute every transfer individually, causing high gas costs and limited scalability.

Paygent v2 introduces:

- **ENS-based strategy configuration** (payment rules stored in ENS text records)
- **Agent-controlled execution layer** (off-chain orchestration)
- **Session-based batch settlement** (single on-chain settlement transaction)
- **Vault-based user balances** (pre-funded payment execution)

This architecture follows a **Yellow Execution Layer pattern**:

```
Strategy (ENS)
     ↓
Agent Executor (off-chain)
     ↓
Batch Execution Session
     ↓
Single Settlement Transaction
     ↓
Merchant Payment
```

---

## System Architecture  

Below is the high-level architecture of Paygent v2:

```
┌──────────────────────────────┐
│           ENS Layer          │
│  Strategy Config (Text)      │
│  - Payment Amount            │
│  - Risk Profile              │
│  - Pool Reference            │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│     Yellow Agent Executor    │   (Off-chain)
│------------------------------│
│ - Fetch ENS Strategy         │
│ - Batch Planning             │
│ - Balance Simulation         │
│ - Session Control            │
│ - Gas Optimization           │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│      PaygentManager          │   (On-chain)
│------------------------------│
│ Vault Layer                  │
│ - User Deposits              │
│ - Internal Balances          │
│                              │
│ Execution Session Layer      │
│ - startSession()             │
│ - executePayment() (batch)   │
│ - Accounting Only            │
│                              │
│ Settlement Layer             │
│ - settleSession()            │
│ - Single Transfer            │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│        Merchant Wallet       │
│   Receives Final Settlement  │
└──────────────────────────────┘
```

---

## Architecture Design Principles  

### Separation of Concerns  

Paygent v2 cleanly separates:

| Layer | Responsibility |
------|----------------
ENS Layer | Strategy configuration storage |
Agent Layer | Execution planning & batching |
Contract Layer | Accounting + settlement |
Merchant Layer | Final fund recipient |

---

### Batch Execution Model  

Instead of transferring funds on every payment:

- Payments are **accounted internally**
- Multiple executions are grouped
- One final settlement transaction is used

This improves:

- Gas efficiency  
- Atomicity  
- Fault tolerance  
- Execution safety  

---

### Agent-Native Design  

The off-chain executor acts as the system "brain":

- Selects batch size  
- Chooses execution timing  
- Simulates balances  
- Controls session lifecycle  

Smart contracts remain **simple, deterministic, and settlement-focused**.

---

## Current Development Progress  

### Phase 1 — Project Setup ✅  

- Foundry project initialized  
- Repository structure configured  
- ENS and OpenZeppelin dependencies installed  
- RPC and wallet configured  

---

### Phase 2 — ENS Strategy Layer ✅  

- ENSStrategyReader contract implemented  
- ENS registry + resolver integration  
- Strategy reading from ENS text records  
- Payment amount parsing using Maths utility  
- Mainnet fork testing completed  

---

### Phase 3 — Paygent Agent Core ✅  

- PaygentManager contract implemented  
- Vault deposit system added  
- User balance accounting implemented  
- ENS integration wired into payment execution  

---

### Phase 4 — Execution Layer (Yellow Integration) 🚧  

Completed so far:

- Session-based execution model added  
- ExecutionSession struct implemented  
- startSession() lifecycle implemented  
- Batch-style executePayment accounting logic  
- Settlement phase abstraction added  
- Event system added:
  - SessionStarted  
  - PaymentExecuted  
  - SessionSettled  

Currently working on:

- Off-chain Yellow executor node  
- Batch simulation logic  
- Execution orchestration  

---

## Current Execution Flow  

```
User Deposit
     ↓
ENS Strategy Fetch
     ↓
Agent Opens Session
     ↓
Batch executePayment() Calls
     ↓
Single settleSession()
     ↓
Merchant Receives Funds
```

---

## Tech Stack  

- Solidity (Foundry)  
- ENS Integration  
- ERC20 Vault Accounting  
- Agent-based Execution Model  
- Yellow-style Session Architecture  

---

## Roadmap  

### Upcoming Milestones  

- Yellow off-chain executor implementation  
- Batch simulation engine  
- Uniswap v4 settlement integration  
- Multi-merchant settlement support  
- End-to-end demo deployment  

---

## Project Vision  

Paygent v2 aims to become a **modular payment coordination layer** enabling:

- Automated subscriptions  
- Liquidity-aware payments  
- Strategy-controlled spending  
- Rollup-compatible batching  
- Agent-native execution  

---


