// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import { XConsole } from "./Console.sol";

import { DSTestPlus } from "@rari-capital/solmate/test/utils/DSTestPlus.sol";

import { stdCheats, stdError } from "@std/stdlib.sol";
import { Vm } from "@std/Vm.sol";

contract DSTestPlusPlus is DSTestPlus, stdCheats {
    XConsole console = new XConsole();

    /// @dev Use forge-std Vm logic
    Vm public constant vm = Vm(HEVM_ADDRESS);
}
