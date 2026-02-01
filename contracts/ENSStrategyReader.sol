//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import { Resolver } from "lib/ens-contracts/contracts/resolvers/Resolver.sol";
//import { NameCoder } from "lib/ens-contracts/contracts/utils/NameCoder.sol";


interface IENSRegistry {
    function resolver(bytes32 node) external view returns (address);
}


contract ENSStrategyReader{

    //using NameCoder for bytes;
    address private immutable I_REGISTRYADDRESS;

    constructor(address registryAddress) {
        I_REGISTRYADDRESS = registryAddress;
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

    function readStrategyTexts(bytes32 node) public view returns (
        string memory pool,
        string memory paymentAmount,
        string memory risk,
        string memory rebalanceThreshold
    ) {
        pool = getTextRecord(node, "pool");
        paymentAmount = getTextRecord(node, "paymentAmount");
        risk = getTextRecord(node, "risk");
        rebalanceThreshold = getTextRecord(node, "rebalanceThreshold");

        return (pool, paymentAmount, risk, rebalanceThreshold);
    }


}