# Paygent v2 — Uniswap v4 Pool Initialization Attempt

> This branch documents the experimental Uniswap v4 liquidity executor and pool
initialization attempt for Paygent v2.

This branch exists to **demonstrate deep Uniswap v4 integration work** while
keeping the main branch stable for the live Sepolia demo.

---

## Overview

Paygent v2 is an agentic subscription payment protocol that supports **pluggable
liquidity strategies**. As part of this design, we implemented a
**Uniswap v4 LiquidityExecutor** that integrates directly with the canonical
Uniswap v4 `PoolManager`.

This branch contains:
- the Uniswap v4 executor contract
- PoolManager-based liquidity deployment logic
- an explicit pool initialization attempt via `PoolManager.initialize`

---

## What Was Implemented

### UniswapV4Executor

The `UniswapV4Executor` contract:

- integrates directly with the Uniswap v4 `PoolManager`
- constructs a canonical `PoolKey` with:
  - correct token ordering
  - explicit fee and tick spacing
  - no hooks (address(0))
- deploys and withdraws liquidity via:
  - `PoolManager.modifyLiquidity`

This executor is fully wired into the Paygent architecture and callable only by
the `PaymentManager`.

---

### Pool Initialization Attempt

Uniswap v4 does not use a factory pattern. Pools exist only after an explicit
initialization call:

```solidity
poolManager.initialize(poolKey, sqrtPriceX96);
