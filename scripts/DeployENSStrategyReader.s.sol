//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import { Script, console2 } from "lib/forge-std/src/Script.sol";
import { ENSStrategyReader } from "../contracts/ENSStrategyReader.sol";

contract DeployENSStrategyReader is Script {

    address immutable ENS_REGISTRY = 0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e;

    function run() external {
        vm.startBroadcast();
        ENSStrategyReader reader = new ENSStrategyReader(ENS_REGISTRY);
        vm.stopBroadcast();

        console2.log("ENSStrategyReader deployed at:", address(reader));

    }
    
}