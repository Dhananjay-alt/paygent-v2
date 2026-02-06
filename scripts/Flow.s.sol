// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import { PaymentManager } from "contracts/PaymentManager.sol";
import { MockUSDC } from "contracts/MockUSDC.sol";

contract Flow is Script {
    function run() external {
        // ====== CONFIG ======
        address MANAGER = vm.envAddress("MANAGER");
        address USDC    = vm.envAddress("USDC");
        address USER    = vm.envAddress("USER");
        bytes32 STRATEGY_NODE = vm.envBytes32("STRATEGY_NODE");

        uint256 USER_PK = vm.envUint("USER_PK");
        uint256 OWNER_PK = vm.envUint("OWNER_PK");

        PaymentManager manager = PaymentManager(MANAGER);
        MockUSDC token = MockUSDC(USDC);

        vm.startBroadcast(OWNER_PK);
        token.mint(USER, 1000e6);
        vm.stopBroadcast();

        // ====== USER FLOW ======
        vm.startBroadcast(USER_PK);

        token.approve(MANAGER, 1000e6);
        manager.deposit(300e6);

        vm.stopBroadcast();

        // ====== OWNER FLOW ======
        vm.startBroadcast(USER_PK);

        manager.deployLiquidityFromVault(USER, 200e6);
        manager.startStrategyExecution(STRATEGY_NODE);

        // local-only time warp
        vm.warp(block.timestamp + 31);

        manager.executeScheduledPayment(USER);

        vm.stopBroadcast();

        console.log("Flow completed successfully");
    }
}
