🛠 Paygent v2 — Development Task Checklist
Phase 1 — Project Setup

 Initialize Foundry project

 Configure repo structure (contracts, tests, scripts, docs)

 Install OpenZeppelin + ENS dependencies

 Setup testnet RPC + wallet

Phase 2 — ENS Strategy Identity Layer

 Implement ENSStrategyReader contract

 Read ENS resolver from registry

 Fetch strategy from ENS text records

 Parse pool, payment amount, risk, threshold

 Write ENSStrategyReader unit tests

Phase 3 — Paygent Agent Core

 Implement PaygentManager contract

 Add deposit and withdrawal logic

 Integrate ENS strategy reader

 Implement basic agent state tracking

 Write PaygentManager tests

Phase 4 — Execution Layer (Yellow Integration)

 Integrate Yellow SDK

 Implement session open / close logic

 Add off-chain execution simulation

 Connect agent logic to Yellow executor

 Log session lifecycle for demo

Phase 5 — Uniswap v4 Settlement Layer

 Implement UniswapExecutor contract

 Add liquidity or swap interaction

 Integrate settlement flow from agent

 Produce on-chain transaction proof

 Write Uniswap integration tests

Phase 6 — Payment Execution

 Implement merchant payment transfer

 Trigger payment from agent logic

 Validate balances after payment

 Add payment test case

Phase 7 — End-to-End Integration

 Connect ENS → Agent → Yellow → Uniswap → Payment

 Run full flow on testnet

 Debug integration issues

 Finalize execution pipeline

Phase 8 — Demo & Submission

 Prepare demo script

 Record 3-minute demo video

 Write architecture documentation

 Add transaction hashes

 Finalize README