// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

library Strings {
    // Reference: https://ethereum.stackexchange.com/questions/13862/is-it-possible-to-check-string-variables-length-inside-the-contract/13886#13886
    function strlen(string memory str) internal pure returns (uint256 length) {
        uint256 i = 0;
        bytes memory string_rep = bytes(str);

        while (i < string_rep.length) {
            if (string_rep[i] >> 7 == 0) i += 1;
            else if (string_rep[i] >> 5 == bytes1(uint8(0x6))) i += 2;
            else if (string_rep[i] >> 4 == bytes1(uint8(0xE))) i += 3;
            else if (string_rep[i] >> 3 == bytes1(uint8(0x1E)))
                i += 4;
                //For safety
            else i += 1;

            length++;
        }
    }
}
