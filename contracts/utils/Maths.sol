//SPDX-LIcense-Identifier: MIT

pragma solidity ^0.8.19;

library Maths {
    function parseInt(string memory _a) internal pure returns (uint256) {
        bytes memory bresult = bytes(_a);
        uint256 mint = 0;
        for (uint256 i = 0; i < bresult.length; i++) {
            if (uint8(bresult[i]) >= 48 && uint8(bresult[i]) <= 57) {
                mint = mint * 10 + (uint8(bresult[i]) - 48);
            }
        }
        return mint;
    }
}