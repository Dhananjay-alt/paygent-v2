# Paygent v2 — Agentic Liquidity & Payment Orchestrator  

Paygent v2 is an **agent-driven liquidity-aware payment orchestration system** that routes user funds through DeFi liquidity pools before performing **batch-based merchant settlement** using a Yellow-style execution abstraction.

The system separates **execution (off-chain planning + on-chain accounting)** from **final settlement (on-chain)**, enabling gas-efficient batching, capital efficiency, and future-proof extensibility for ZK proofs and rollup-style settlement.

---

## Core Idea  

Traditional on-chain payments keep funds idle and execute every transfer individually, leading to:

- High gas costs  
- Capital inefficiency  
- Limited scalability  

Paygent v2 introduces:

- **ENS-based strategy configuration** (payment + liquidity rules stored on-chain)
- **Agent-controlled execution layer** (off-chain orchestration)
- **Liquidity routing before settlement** (capital utilization phase)
- **Session-based batch settlement** (single on-chain merchant payout)
- **Vault-based user balances** (pre-funded execution layer)

This architecture follows a **Yellow Execution Layer pattern combined with DeFi liquidity orchestration**:

```
Strategy (ENS)
     ↓
Agent Executor (off-chain)
     ↓
Execution Session
     ↓
Liquidity Pool Routing
     ↓
Batch Settlement
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
│  - Rebalance Threshold       │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│     Yellow Agent Executor    │   (Off-chain)
│------------------------------│
│ - Fetch ENS Strategy         │
│ - Batch Planning             │
│ - Balance Simulation         │
│ - Liquidity Routing Logic    │
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
│ Settlement Orchestrator      │
│ - Trigger Liquidity Routing  │
│ - settleSession()            │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│     Liquidity Pool Layer     │
│  (Uniswap v4 / DeFi Pools)   │
│------------------------------│
│ - Temporary Capital Routing  │
│ - Yield / Swap Execution     │
│ - Strategy-Based Allocation  │
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
Agent Layer | Execution planning + liquidity routing |
Contract Layer | Accounting + settlement |
Liquidity Layer | Capital utilization |
Merchant Layer | Final fund recipient |

---

### Liquidity-Aware Execution  

Unlike traditional payment rails, Paygent v2:

- Routes capital through DeFi pools before settlement  
- Avoids idle funds  
- Enables strategy-controlled liquidity usage  
- Preserves atomic merchant settlement  

---

### Batch Execution Model  

Instead of transferring funds on every payment:

- Payments are **accounted internally**
- Multiple executions are grouped
- Liquidity routing is coordinated off-chain
- One final settlement transaction is used

This improves:

- Gas efficiency  
- Atomicity  
- Fault tolerance  
- Capital utilization  

---

### Agent-Native Design  

The off-chain executor acts as the system control layer:

- Selects batch size  
- Chooses liquidity routes  
- Simulates balances  
- Controls session lifecycle  
- Optimizes execution timing  

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
- Liquidity routing integration  
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
Batch Accounting Execution
     ↓
Liquidity Pool Routing
     ↓
Single Settlement Transaction
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
- Uniswap v4 (Planned Liquidity Layer)  

---

## Roadmap  

### Upcoming Milestones  

- Yellow off-chain executor implementation  
- Liquidity routing engine  
- Uniswap v4 settlement integration  
- Multi-merchant settlement support  
- End-to-end demo deployment  

---

## Project Vision  

Paygent v2 aims to become a **liquidity-aware programmable payment execution layer** enabling:

- Automated subscriptions  
- Yield-aware payments  
- Strategy-controlled spending  
- Capital-efficient settlement  
- Rollup-compatible batching  
- Agent-native execution  

---

Built for hackathon-scale experimentation and future production-grade extensibility.

