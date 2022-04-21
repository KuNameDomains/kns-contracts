// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import { NameRegistryDummy } from "./NameRegistryDummy.sol";
import { DSTestPlusPlus } from "../utils/DSTestPlusPlus.sol";

error Unauthorized();

contract RejectiveRegistryStub is NameRegistryDummy, DSTestPlusPlus {
    constructor() {
        vm.mockCall(
            address(this),
            abi.encodeWithSelector(NameRegistryDummy.setSubnodeOwner.selector),
            abi.encode(bytes32(""))
        );

        vm.mockCall(address(this), abi.encodeWithSelector(NameRegistryDummy.recordExists.selector), abi.encode(true));
    }

    function setSubnodeOwner(
        bytes32 node,
        bytes32 label,
        address _owner
    ) public virtual override returns (bytes32) {
        node;
        label;
        _owner;
        revert Unauthorized();
    }
}
