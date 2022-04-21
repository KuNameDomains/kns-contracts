// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import { NameRegistry } from "../../src/interfaces/NameRegistry.sol";

contract NameRegistryDummy is NameRegistry {
    function setRecord(
        bytes32 node,
        address _owner,
        address _resolver,
        uint64 _ttl
    ) external virtual override {}

    function setSubnodeRecord(
        bytes32 node,
        bytes32 label,
        address _owner,
        address _resolver,
        uint64 _ttl
    ) external virtual override {}

    function setOwner(bytes32 node, address _owner) public virtual override {}

    function setSubnodeOwner(
        bytes32 node,
        bytes32 label,
        address _owner
    ) public virtual override returns (bytes32) {}

    function setResolver(bytes32 node, address _resolver) public virtual override {}

    function setTTL(bytes32 node, uint64 _ttl) public virtual override {}

    function owner(bytes32 node) public view virtual override returns (address) {}

    function resolver(bytes32 node) public view virtual override returns (address) {}

    function ttl(bytes32 node) public view virtual override returns (uint64) {}

    function recordExists(bytes32 node) public view virtual override returns (bool) {}

    function balanceOf(address _owner) external view virtual override returns (uint256 balance) {}

    function ownerOf(uint256 tokenId) external view virtual override returns (address _owner) {}

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external virtual override {}

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external virtual override {}

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external virtual override {}

    function approve(address to, uint256 tokenId) external virtual override {}

    function setApprovalForAll(address operator, bool _approved) external virtual override {}

    function getApproved(uint256 tokenId) external view virtual override returns (address operator) {}

    function isApprovedForAll(address _owner, address operator) external view virtual override returns (bool) {}

    function supportsInterface(bytes4 interfaceId) external view virtual override returns (bool) {}
}
