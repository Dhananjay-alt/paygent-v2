// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "lib/forge-std/src/Script.sol";

import "lib/ens-contracts/contracts/registry/ENSRegistry.sol";
//import "lib/ens-contracts/contracts/resolvers/PublicResolver.sol";
//import { TextResolver } from "lib/ens-contracts/contracts/resolvers/profiles/TextResolver.sol";
import "../contracts/ens/SimpleTextResolver.sol";

contract DeployENS is Script {
    function run() external {
        vm.startBroadcast();

        // 1️⃣ Deploy ENS Registry
        ENSRegistry registry = new ENSRegistry();

        // 2️⃣ Deploy SimpleTextResolver
        SimpleTextResolver resolver = new SimpleTextResolver(registry);

        vm.stopBroadcast();

        console.log("ENS Registry:", address(registry));
        console.log("Resolver:", address(resolver));
    }
}
