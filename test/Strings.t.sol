// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import { DSTestPlusPlus } from "./utils/DSTestPlusPlus.sol";
import { Strings } from "../src/libraries/Strings.sol";

contract StringsTest is DSTestPlusPlus {
    using Strings for string;

    struct LengthTestCase {
        string str;
        uint256 len;
    }

    function testLength() public {
        LengthTestCase[6] memory tests = [
            LengthTestCase("", 0),
            LengthTestCase("Hello", 5),
            LengthTestCase(unicode"Привет", 6),
            LengthTestCase(unicode"你好", 2),
            LengthTestCase(unicode"هيلو", 4),
            LengthTestCase(unicode"مرحبا", 5)
        ];

        for (uint256 i = 0; i < tests.length; i++) {
            assertEq(tests[i].str.strlen(), tests[i].len);
        }
    }
}
