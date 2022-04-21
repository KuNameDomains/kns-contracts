// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import { NameRegistrar } from "./interfaces/NameRegistrar.sol";
import { Strings } from "./libraries/Strings.sol";

error UnavailableName();

contract FIFORegistrarController {
    using Strings for string;

    NameRegistrar public immutable registrar;

    constructor(NameRegistrar _registrar) {
        registrar = _registrar;
    }

    function valid(string memory name) public pure returns (bool) {
        return name.strlen() >= 0;
    }

    function available(string memory name) public view returns (bool) {
        return valid(name) && registrar.available(name);
    }

    function register(string calldata name, address owner) public {
        if (!available(name)) {
            revert UnavailableName();
        }

        registrar.register(name, owner);
    }
}
