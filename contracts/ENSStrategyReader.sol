//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { Resolver } from "lib/ens-contracts/contracts/resolvers/Resolver.sol";
//import { NameCoder } from "lib/ens-contracts/contracts/utils/NameCoder.sol";
import { Maths } from "./utils/Maths.sol";


interface IENSRegistry {
    function resolver(bytes32 node) external view returns (address);
}


contract ENSStrategyReader{

    //using NameCoder for bytes;
    address private immutable I_REGISTRYADDRESS;
    using Maths for string;

    constructor(address registryAddress) {
        I_REGISTRYADDRESS = registryAddress;
    }
    struct Strategy {
    string merchant;
    string pool;
    uint256 paymentAmount;
    uint256 paymentInterval;
    uint256 rebalanceThreshold;
    }


    /*function namehash(string calldata name) public pure returns (bytes32) {
        bytes memory nameBytes = bytes(name);

        return nameBytes.namehash(0);
    }*/

    function getResolver (bytes32 node) internal view returns (address) {
        address resolverAddress = IENSRegistry(I_REGISTRYADDRESS).resolver(node);

        require(resolverAddress != address(0), "Resolver not set");
        return resolverAddress;
    }

    function getTextRecord(bytes32 node, string memory key) public view returns (string memory) {
        address resolverAddress = getResolver(node);
        return Resolver(resolverAddress).text(node, key);
    }

    function readStrategy(bytes32 node) external view returns (Strategy memory s) {

    s.merchant = getTextRecord(node, "merchant");
    s.pool = getTextRecord(node, "pool");
    s.paymentAmount = getTextRecord(node, "paymentAmount").parseInt();
    s.paymentInterval = getTextRecord(node, "paymentInterval").parseInt();
    s.rebalanceThreshold = getTextRecord(node, "rebalanceThreshold").parseInt();

    }



}