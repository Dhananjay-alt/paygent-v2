// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import "../contracts/MockUSDC.sol";

contract DeployMockUSDC is Script {
    function run() external {
        vm.startBroadcast();
        MockUSDC mockUSDC = new MockUSDC();
        console.log("MockUSDC deployed at:", address(mockUSDC));

        vm.stopBroadcast();

        
    }
}
