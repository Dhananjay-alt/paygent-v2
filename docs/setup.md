Perfect — below is a **clean, copy-paste-ready installation & usage guide** you can put straight into
`docs/installation.md` (or `docs/setup.md`).

It’s **judge-safe**, **repo-friendly**, and assumes **Foundry users** (which is correct for your project).

---

````md
# Installation & Setup Guide

This guide explains how to install, build, and run Paygent v2 locally, and how the Sepolia demo was executed.

---

## Prerequisites

You will need:

- **Git**
- **Foundry** (forge, cast)
- **Node.js** (for ENS tooling, optional)
- An Ethereum wallet private key (testnet only)
- Access to a Sepolia RPC endpoint

---

## Install Foundry

If you don’t already have Foundry:

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
````

Verify installation:

```bash
forge --version
cast --version
```

---

## Clone the Repository

```bash
git clone https://github.com/<your-org-or-username>/paygent-v2.git
cd paygent-v2
```

---

## Install Dependencies

Paygent v2 uses Git submodules for external dependencies (including Chainlink).

```bash
git submodule update --init --recursive
```

---

## Build the Project

```bash
forge build
```

The build should complete without errors.

---

## Environment Variables

Create environment variables for Sepolia interaction:

```bash
export SEPOLIA_RPC_URL=<your_sepolia_rpc_url>
export PRIVATE_KEY=<your_testnet_private_key>
```

Optional (for verification):

```bash
export ETHERSCAN_API_KEY=<your_etherscan_key>
```

---

## Local Testing

Run the test suite:

```bash
forge test
```

This validates:

* vault accounting
* executor liquidity handling
* withdrawal safety checks

---

## Deployment Flow (Sepolia)

The demo deployment followed this sequence:

1. Deploy mock USDC
2. Deploy ENS registry / resolver (if needed)
3. Deploy `PaymentManager`
4. Deploy liquidity executor
5. Deploy `PaymentAutomation`
6. Configure ENS strategy
7. Deploy liquidity from vault to executor
8. Register Chainlink Automation upkeep

Scripts for these steps are available under:

```
scripts/
```

---

## Automation Demo (Sepolia)

Paygent v2 was demonstrated live on Sepolia using Chainlink Automation.

### Execution Conditions

Automation executes only when:

* execution mode is active
* payment interval has elapsed
* liquidity is explicitly deployed to the executor

### Verification

Automation execution can be verified by checking:

* Chainlink Automation history (`Perform Upkeep`)
* `PaymentExecuted` events
* ERC20 `Transfer` events to the merchant

All relevant contract addresses are listed in:

```
docs/sepolia-addresses.txt
```

---

## Important Notes

* Vault funds are **not executable by default**
* Liquidity must be explicitly deployed to the executor
* Automation cannot bypass protocol safety checks
* ENS configuration is resolved on-chain at execution time

---

## Summary

This setup demonstrates how Paygent v2 combines:

* ENS for live configuration
* Explicit liquidity control
* On-chain automation

to enable safe, autonomous subscription payments.

```

---

## ✅ Where this fits in your repo

Recommended structure:

```

docs/
├─ installation.md   ← this file
├─ architecture.md
├─ automation.md
├─ demo-verification.md
├─ sepolia-addresses.txt



