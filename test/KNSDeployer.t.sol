// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import { DSTestPlusPlus } from "./utils/DSTestPlusPlus.sol";
import { KNSDeployer } from "../src/KNSDeployer.sol";
import { KNSRegistry } from "../src/KNSRegistry.sol";

contract KNSDeployerTest is DSTestPlusPlus {
    KNSDeployer deployer;

    function setUp() public {
        deployer = new KNSDeployer();
    }

    function testOwnership() public {
        KNSRegistry registry = deployer.kns();
        bytes32 tldNode = keccak256(abi.encodePacked(bytes32(0), deployer.TLD_LABEL()));

        assertEq(registry.owner(bytes32(0)), address(this));
        assertEq(registry.owner(tldNode), address(deployer.registrar()));
    }
}
