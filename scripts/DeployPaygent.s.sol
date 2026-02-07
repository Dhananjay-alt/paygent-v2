// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";

import "../contracts/ENSStrategyReader.sol";
import "../contracts/PaymentManager.sol";
import "../contracts/UniswapV4Executor.sol";
import "../contracts/MockUSDC.sol";
import "../contracts/PaymentAutomation.sol";

contract DeployPaygent is Script {
    // Sepolia ENS Registry (OFFICIAL)
    address constant ENS_REGISTRY = 0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e;
    address constant SEPLOIA_POOL_MANAGER =
        0xE03A1074c86CFeDd5C142C4F04F1a1536e203543;

    function run() external {
        vm.startBroadcast();

        // 1. Deploy Mock USDC
        MockUSDC mockUSDC = new MockUSDC();
        console2.log("MockUSDC deployed at:", address(mockUSDC));

        // 2. Deploy ENS Strategy Reader
        ENSStrategyReader reader = new ENSStrategyReader(ENS_REGISTRY);
        console2.log("ENSStrategyReader deployed at:", address(reader));

        // 3. Deploy PaymentManager (WITHOUT executor for now)
        PaymentManager paymentManager = new PaymentManager(
            address(mockUSDC),
            address(reader)
        );
        console2.log("PaymentManager deployed at:", address(paymentManager));

        // 4. Deploy Executor
        // 2. Deploy UniswapV4Executor
        UniswapV4Executor uniExecutor = new UniswapV4Executor(
            address(paymentManager),
            address(mockUSDC),
            SEPLOIA_POOL_MANAGER
        );

        console2.log("UniswapV4Executor deployed:", address(uniExecutor));

        // 5. Wire executor
        paymentManager.setExecutor(address(uniExecutor));
        console2.log("Executor set in PaymentManager");

        PaymentAutomation automation = new PaymentAutomation(
            address(paymentManager),
            msg.sender // or explicit user address
        );

        console2.log("Automation deployed:", address(automation));

        vm.stopBroadcast();
    }
}
