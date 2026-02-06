//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import { Script, console2 } from "lib/forge-std/src/Script.sol";
import  "../contracts/ENSStrategyReader.sol";
import "../contracts/PaymentManager.sol";
import "../contracts/MockLiquidityExecutor.sol";
import "../contracts/MockUSDC.sol";


//address constant ENS_REGISTRY = 0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e;



contract DeployPaygent is Script {
    address ENS_REGISTRY;
    function run() external {

        ENS_REGISTRY = vm.envAddress("ENS_REGISTRY");

        vm.startBroadcast();



        MockUSDC mockUSDC = new MockUSDC();
        console2.log("MockUSDC deployed at:", address(mockUSDC));

        ENSStrategyReader reader = new ENSStrategyReader(ENS_REGISTRY);
        console2.log("ENSStrategyReader deployed at:", address(reader));

        PaymentManager paymentManager = new PaymentManager(address(mockUSDC), address(reader));
        console2.log("PaymentManager deployed at:", address(paymentManager));
    
        MockLiquidityExecutor mockExecutor = new MockLiquidityExecutor(address(mockUSDC));
        console2.log("MockLiquidityExecutor deployed at:", address(mockExecutor));

        paymentManager.setExecutor(address(mockExecutor));
        console2.log("Executor set in PaymentManager");

        vm.stopBroadcast();
    }
    
}