// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "lib/ens-contracts/contracts/registry/ENS.sol";

contract SimpleTextResolver {
    ENS public immutable ens;

    // node => key => value
    mapping(bytes32 => mapping(string => string)) private records;

    event TextChanged(bytes32 indexed node, string indexed key, string value);

    constructor(ENS _ens) {
        ens = _ens;
    }

    // ENS-compatible text read
    function text(bytes32 node, string calldata key)
        external
        view
        returns (string memory)
    {
        return records[node][key];
    }

    // ENS-compatible text write
    function setText(
        bytes32 node,
        string calldata key,
        string calldata value
    ) external {
        require(msg.sender == ens.owner(node), "Not node owner");
        records[node][key] = value;
        emit TextChanged(node, key, value);
    }
}
