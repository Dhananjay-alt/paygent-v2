// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Script, console } from  "lib/forge-std/src/Script.sol";

import "lib/ens-contracts/contracts/registry/ENSRegistry.sol";
//import "lib/ens-contracts/contracts/resolvers/PublicResolver.sol";
//import { TextResolver } from "lib/ens-contracts/contracts/resolvers/profiles/TextResolver.sol";
import { SimpleTextResolver } from "../contracts/ens/SimpleTextResolver.sol";

contract DeployENS is Script {
    function run() external {
        vm.startBroadcast();

        // 1️⃣ Deploy ENS Registry
        ENSRegistry registry = new ENSRegistry();
        bytes32 ethNode = keccak256(
            abi.encodePacked(bytes32(0), keccak256("eth"))
        );

        registry.setSubnodeOwner(
            bytes32(0), // root node
            keccak256("eth"), // label
            msg.sender // owner
        );

        // 2️⃣ Deploy SimpleTextResolver
        SimpleTextResolver resolver = new SimpleTextResolver(registry);
        registry.setResolver(ethNode, address(resolver));

        vm.stopBroadcast();

        console.log("ENS Registry:", address(registry));
        console.log("Resolver:", address(resolver));
    }
}
