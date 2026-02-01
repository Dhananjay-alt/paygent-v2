//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import { Test } from "lib/forge-std/src/Test.sol";
import { ENSStrategyReader } from "../contracts/ENSStrategyReader.sol";

contract ENSStrategyReaderTest is Test {
    ENSStrategyReader public reader;

    address constant ENS_REGISTRY = 0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e;

    function setUp() external {
        DeployENSStrategyReader deployer = new DeployENSStrategyReader();
        
        reader = new ENSStrategyReader(ENS_REGISTRY);
    }

    
}