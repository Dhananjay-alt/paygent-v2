// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import { PaymentAutomation } from "contracts/PaymentAutomation.sol";

contract DeployPaymentAutomation is Script {
    function run() external {
        address paygentManager = vm.envAddress("PAYGENT_MANAGER");
        address user = vm.envAddress("PAYGENT_USER");

        vm.startBroadcast();

        PaymentAutomation PaymentAutomation = new PaymentAutomation(paygentManager, user);
        console.log("PaymentAutomation deployed at:", address(PaymentAutomation));
        vm.stopBroadcast();
    }
}
