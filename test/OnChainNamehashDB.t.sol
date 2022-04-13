// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import { DSTestPlusPlus } from "./utils/DSTestPlusPlus.sol";
import { OnChainNamehashDB } from "../src/OnChainNamehashDB.sol";

contract OnChainNamehashDBTest is DSTestPlusPlus {
    OnChainNamehashDB namehashDB;

    function setUp() public {
        namehashDB = new OnChainNamehashDB();
    }

    function testTLDStore(string memory tld) public {
        bytes32 tldhash = keccak256(abi.encodePacked(tld));
        bytes32 node = keccak256(abi.encodePacked(bytes32(0), tldhash));

        namehashDB.store(bytes32(0), tld);
        string memory name = namehashDB.lookup(node);

        assertEq0(bytes(name), bytes(tld));
    }

    function testSLDStore(string memory tld, string memory sld) public {
        bytes32 tldhash = keccak256(abi.encodePacked(tld));
        bytes32 sldhash = keccak256(abi.encodePacked(sld));
        bytes32 node = keccak256(abi.encodePacked(bytes32(0), tldhash));
        bytes32 subnode = keccak256(abi.encodePacked(node, sldhash));

        namehashDB.store(bytes32(0), tld);
        namehashDB.store(node, sld);

        string memory name = namehashDB.lookup(node);
        assertEq0(bytes(name), bytes(tld));

        name = namehashDB.lookup(subnode);
        assertEq0(bytes(name), abi.encodePacked(sld, ".", tld));
    }

    function testEmptyLookup(string memory domain) public {
        string memory name = namehashDB.lookup(keccak256(abi.encodePacked(domain)));
        assertEq0(bytes(name), bytes(""));
    }
}
