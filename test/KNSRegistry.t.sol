// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import { DSTestPlusPlus } from "./utils/DSTestPlusPlus.sol";
import { KNSRegistry, Unauthorized } from "../src/KNSRegistry.sol";

contract KNSRegistryTest is DSTestPlusPlus {
    KNSRegistry registry;

    function setUp() public {
        registry = new KNSRegistry();
    }

    function testSetOwner(address owner) public {
        bytes32 node = bytes32(0);

        vm.assume(owner != address(0));
        vm.assume(owner != address(this));
        vm.assume(owner != address(registry));

        assertEq(registry.owner(node), address(this));

        registry.setOwner(node, owner);
        vm.expectRevert(Unauthorized.selector);
        registry.setOwner(node, address(this));
    }

    function testSetSubnodeOwner(
        string calldata tld,
        string calldata sld,
        address owner
    ) public {
        vm.assume(owner != address(0));
        vm.assume(owner != address(this));
        vm.assume(owner != address(registry));

        bytes32 tldhash = keccak256(abi.encodePacked(tld));
        bytes32 sldhash = keccak256(abi.encodePacked(sld));

        bytes32 node = registry.setSubnodeOwner(bytes32(0), tldhash, owner);
        assertEq(node, keccak256(abi.encodePacked(bytes32(0), tldhash)));
        assertEq(registry.owner(node), owner);

        vm.expectRevert(Unauthorized.selector);
        registry.setSubnodeOwner(node, sldhash, owner);
    }

    function testSetResolver(
        bytes32 label,
        address resolver,
        address owner
    ) public {
        bytes32 node = bytes32(0);

        vm.assume(owner != address(0));
        vm.assume(owner != address(this));
        vm.assume(owner != address(registry));

        registry.setResolver(node, resolver);
        assertEq(registry.resolver(node), resolver);

        bytes32 subnode = registry.setSubnodeOwner(node, label, owner);
        vm.expectRevert(Unauthorized.selector);
        registry.setResolver(subnode, resolver);
    }

    function testSetTTL(
        bytes32 label,
        uint64 ttl,
        address owner
    ) public {
        bytes32 node = bytes32(0);

        vm.assume(owner != address(0));
        vm.assume(owner != address(this));
        vm.assume(owner != address(registry));

        registry.setTTL(node, ttl);
        assertEq(registry.ttl(node), ttl);

        bytes32 subnode = registry.setSubnodeOwner(node, label, owner);
        vm.expectRevert(Unauthorized.selector);
        registry.setTTL(subnode, ttl);
    }

    function testSetRecord(
        address owner,
        address resolver,
        uint64 ttl
    ) public {
        bytes32 node = bytes32(0);

        vm.assume(owner != address(0));
        vm.assume(owner != address(this));
        vm.assume(owner != address(registry));

        assertTrue(registry.recordExists(node));
        registry.setRecord(node, owner, resolver, ttl);
        assertEq(registry.owner(node), owner);
        assertEq(registry.resolver(node), resolver);
        assertEq(registry.ttl(node), ttl);

        vm.expectRevert(Unauthorized.selector);
        registry.setRecord(node, owner, resolver, ttl);
    }

    function testSetApprovalForAll(
        bytes32 tld,
        bytes32 sld,
        address operator
    ) public {
        vm.assume(operator != address(this));
        vm.assume(operator != address(registry));
        vm.assume(operator != address(0));

        address owner = address(this);
        bytes32 subnode = registry.setSubnodeOwner(bytes32(0), tld, owner);

        vm.startPrank(operator);
        vm.expectRevert(Unauthorized.selector);
        registry.setOwner(subnode, owner);
        vm.expectRevert(Unauthorized.selector);
        registry.setSubnodeOwner(subnode, sld, owner);
        vm.expectRevert(Unauthorized.selector);
        registry.setRecord(subnode, owner, address(0), 0);
        vm.expectRevert(Unauthorized.selector);
        registry.setResolver(subnode, address(0));
        vm.expectRevert(Unauthorized.selector);
        registry.setTTL(subnode, 0);
        vm.stopPrank();

        registry.setApprovalForAll(operator, true);
        assertTrue(registry.isApprovedForAll(owner, operator));

        vm.startPrank(operator);
        registry.setOwner(subnode, owner);
        registry.setSubnodeOwner(subnode, sld, owner);
        registry.setRecord(subnode, owner, address(0), 0);
        registry.setResolver(subnode, address(0));
        registry.setTTL(subnode, 0);
        vm.stopPrank();

        registry.setApprovalForAll(operator, false);
        assertFalse(registry.isApprovedForAll(owner, operator));

        vm.startPrank(operator);
        vm.expectRevert(Unauthorized.selector);
        registry.setOwner(subnode, owner);
        vm.expectRevert(Unauthorized.selector);
        registry.setSubnodeOwner(subnode, sld, owner);
        vm.expectRevert(Unauthorized.selector);
        registry.setRecord(subnode, owner, address(0), 0);
        vm.expectRevert(Unauthorized.selector);
        registry.setResolver(subnode, address(0));
        vm.expectRevert(Unauthorized.selector);
        registry.setTTL(subnode, 0);
        vm.stopPrank();
    }

    function testTransferFrom(address owner) public {
        uint256 nodeID = uint256(0);

        vm.assume(owner != address(0));
        vm.assume(owner != address(this));
        vm.assume(owner != address(registry));

        assertEq(registry.ownerOf(nodeID), address(this));

        registry.transferFrom(address(this), owner, nodeID);
        assertEq(registry.ownerOf(nodeID), owner);

        vm.expectRevert(bytes("ERC721: transfer caller is not owner nor approved"));
        registry.transferFrom(owner, address(this), nodeID);
    }

    function testSafeTransferFrom(address owner) public {
        uint256 nodeID = uint256(0);

        vm.assume(owner != address(0));
        vm.assume(owner != address(this));
        vm.assume(owner != address(registry));

        assertEq(registry.ownerOf(nodeID), address(this));

        registry.safeTransferFrom(address(this), owner, nodeID);
        assertEq(registry.ownerOf(nodeID), owner);

        vm.expectRevert(bytes("ERC721: transfer caller is not owner nor approved"));
        registry.safeTransferFrom(owner, address(this), nodeID);
    }

    function testCannotBurn() public {
        bytes32 tldHash = keccak256(abi.encodePacked("tld"));
        bytes32 node = registry.setSubnodeOwner(bytes32(0), tldHash, address(this));

        vm.expectRevert(bytes("ERC721: transfer to the zero address"));
        registry.transferFrom(address(this), address(0), uint256(node));

        vm.expectRevert(bytes("ERC721: transfer to the zero address"));
        registry.safeTransferFrom(address(this), address(0), uint256(node));

        vm.expectRevert(bytes("ERC721: transfer to the zero address"));
        registry.setOwner(node, address(0));

        vm.expectRevert(bytes("ERC721: transfer to the zero address"));
        registry.setSubnodeOwner(bytes32(0), tldHash, address(0));

        vm.expectRevert(bytes("ERC721: transfer to the zero address"));
        registry.setRecord(node, address(0), address(1), 0);

        vm.expectRevert(bytes("ERC721: transfer to the zero address"));
        registry.setSubnodeRecord(bytes32(0), tldHash, address(0), address(1), 0);
    }

    function testPauseUnpause() public {
        bytes32 tld1Hash = keccak256(abi.encodePacked("tld1"));
        bytes32 tld2Hash = keccak256(abi.encodePacked("tld2"));
        bytes32 sldHash = keccak256(abi.encodePacked("sld"));

        assertFalse(registry.paused());

        bytes32 tldNode = registry.setSubnodeOwner(bytes32(0), tld1Hash, address(this));
        registry.setSubnodeOwner(tldNode, sldHash, address(this));
        registry.transferFrom(address(this), address(this), uint256(tldNode));

        registry.pause();
        assertTrue(registry.paused());

        vm.expectRevert("Pausable: paused");
        registry.setRecord(bytes32(0), address(1), address(1), 0);

        vm.expectRevert("Pausable: paused");
        registry.setSubnodeRecord(bytes32(0), tld2Hash, address(1), address(1), 0);

        vm.expectRevert("Pausable: paused");
        registry.setSubnodeOwner(bytes32(0), tld2Hash, address(this));

        vm.expectRevert("Pausable: paused");
        registry.setOwner(bytes32(0), address(this));

        vm.expectRevert("Pausable: paused");
        registry.transferFrom(address(this), address(this), uint256(tldNode));

        vm.expectRevert("Pausable: paused");
        registry.safeTransferFrom(address(this), address(this), uint256(tldNode));

        registry.unpause();
        assertFalse(registry.paused());

        bytes32 sldNode = registry.setSubnodeOwner(tldNode, sldHash, address(this));
        registry.transferFrom(address(this), address(this), uint256(sldNode));
    }

    function testPauseUnpauseUnauthorized() public {
        vm.startPrank(address(1));

        vm.expectRevert(Unauthorized.selector);
        registry.pause();

        vm.expectRevert(Unauthorized.selector);
        registry.unpause();
    }
}
