//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

library AddressParser {
    function parseAddress(string memory s) internal pure returns (address) {
    bytes memory b = bytes(s);

    // must be exactly 42 chars: 0x + 40 hex
    require(b.length == 42, "ENS merchant: bad length");
    require(b[0] == "0" && (b[1] == "x" || b[1] == "X"), "ENS merchant: bad prefix");

    uint160 result = 0;

    for (uint256 i = 2; i < 42; i++) {
        result <<= 4;
        uint8 c = uint8(b[i]);

        if (c >= 48 && c <= 57) {
            result |= uint160(c - 48);
        } else if (c >= 65 && c <= 70) {
            result |= uint160(c - 55);
        } else if (c >= 97 && c <= 102) {
            result |= uint160(c - 87);
        } else {
            revert("ENS merchant: bad hex char");
        }
    }

    return address(result);
}


}