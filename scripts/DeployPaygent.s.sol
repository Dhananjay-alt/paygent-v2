// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Script, console2 } from "forge-std/Script.sol";

import "../contracts/ENSStrategyReader.sol";
import "../contracts/PaymentManager.sol";
import "../contracts/MockLiquidityExecutor.sol";
import "../contracts/MockUSDC.sol";

contract DeployPaygent is Script {
    // Sepolia ENS Registry (OFFICIAL)
    address constant ENS_REGISTRY =
        0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e;

    function run() external {
        vm.startBroadcast();

        // 1. Deploy Mock USDC
        MockUSDC mockUSDC = new MockUSDC();
        console2.log("MockUSDC deployed at:", address(mockUSDC));

        // 2. Deploy ENS Strategy Reader
        ENSStrategyReader reader = new ENSStrategyReader(ENS_REGISTRY);
        console2.log("ENSStrategyReader deployed at:", address(reader));

        // 3. Deploy PaymentManager (WITHOUT executor for now)
        PaymentManager paymentManager =
            new PaymentManager(address(mockUSDC), address(reader));
        console2.log("PaymentManager deployed at:", address(paymentManager));

        // 4. Deploy Executor
        MockLiquidityExecutor mockExecutor =
            new MockLiquidityExecutor(address(mockUSDC));
        console2.log("MockLiquidityExecutor deployed at:", address(mockExecutor));

        // 5. Wire executor
        paymentManager.setExecutor(address(mockExecutor));
        console2.log("Executor set in PaymentManager");

        vm.stopBroadcast();
    }
}
