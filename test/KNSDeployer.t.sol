// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import { DSTestPlusPlus } from "./utils/DSTestPlusPlus.sol";
import { KNSDeployer } from "../src/KNSDeployer.sol";
import { KNSRegistry } from "../src/KNSRegistry.sol";
import { KNSRegistrar } from "../src/KNSRegistrar.sol";
import { KNSReverseRegistrar } from "../src/KNSReverseRegistrar.sol";

contract KNSDeployerTest is DSTestPlusPlus {
    KNSDeployer deployer;

    function setUp() public {
        deployer = new KNSDeployer();
    }

    function testOwnership() public {
        KNSRegistry registry = deployer.registry();
        KNSRegistrar registrar = deployer.registrar();
        KNSReverseRegistrar reverseRegistrar = deployer.reverseRegistrar();
        bytes32 tldNode = keccak256(abi.encodePacked(bytes32(0), deployer.TLD_LABEL()));

        assertEq(registry.owner(bytes32(0)), address(this));
        assertEq(registry.owner(tldNode), address(registrar));
        assertEq(registrar.owner(), address(this));
        assertEq(reverseRegistrar.owner(), address(this));
    }
}
