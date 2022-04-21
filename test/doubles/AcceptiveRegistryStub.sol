// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import { NameRegistryDummy } from "./NameRegistryDummy.sol";
import { DSTestPlusPlus } from "../utils/DSTestPlusPlus.sol";

contract AcceptiveRegistryStub is NameRegistryDummy, DSTestPlusPlus {
    constructor() {
        vm.mockCall(
            address(this),
            abi.encodeWithSelector(NameRegistryDummy.setSubnodeOwner.selector),
            abi.encode(bytes32(""))
        );

        vm.mockCall(address(this), abi.encodeWithSelector(NameRegistryDummy.recordExists.selector), abi.encode(false));
    }
}
