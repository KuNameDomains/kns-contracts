// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import { DSTestPlusPlus } from "./utils/DSTestPlusPlus.sol";
import { NamehashDBDeployer } from "../src/NamehashDBDeployer.sol";
import { KNSDeployer } from "../src/KNSDeployer.sol";
import { KNSMultifetcher } from "../src/KNSMultifetcher.sol";

contract KNSMultifetcherTest is DSTestPlusPlus {
    KNSDeployer deployer;
    KNSMultifetcher multifetcher;

    function setUp() public {
        deployer = new KNSDeployer((new NamehashDBDeployer()).namehashDB());
        multifetcher = new KNSMultifetcher(deployer.registry(), deployer.namehashDB());
    }

    function testNamesOfOwner() public view {
        string[] memory names = multifetcher.namesOfOwner(address(this));
        assert(names.length == 3);
    }
}
