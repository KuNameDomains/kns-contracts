// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import { NameRegistry } from "./interfaces/NameRegistry.sol";
import { NamehashDB } from "./interfaces/NamehashDB.sol";
import "@ensdomains/ens-contracts/contracts/resolvers/profiles/AddrResolver.sol";
import "@ensdomains/ens-contracts/contracts/resolvers/profiles/NameResolver.sol";
import "@ensdomains/ens-contracts/contracts/resolvers/profiles/TextResolver.sol";

/// @title KNS Multifetcher
/// @author Gilgames <gilgames@kuname.domains>
/// @notice This contract implements utility functions used to fetch multiple
///         records, names, and aggregate information in a single RPC call.
contract KNSMultifetcher {
    struct NodeMetadata {
        address owner;
        address resolver;
        DefaultRecords canonicalRecords;
    }

    struct DefaultRecords {
        string name;
        address addr;
        TextRecord[] textRecords;
    }

    struct TextRecord {
        string key;
        string value;
    }

    NameRegistry public immutable registry;
    NamehashDB public immutable namehashDB;

    string[] public defaultTextRecordsKeys = [
        "email",
        "url",
        "avatar",
        "description",
        "notice",
        "keywords",
        "com.twitter",
        "com.discord",
        "org.telegram",
        "com.github",
        "com.reddit"
    ];

    constructor(NameRegistry _registry, NamehashDB _namehashDB) {
        registry = _registry;
        namehashDB = _namehashDB;
    }

    function textRecordsOfNode(bytes32 _node, string[] calldata _keys)
        public
        view
        returns (TextRecord[] memory textRecords)
    {
        address resolver = registry.resolver(_node);
        if (resolver == address(0)) {
            return textRecords;
        }

        textRecords = new TextRecord[](_keys.length);
        for (uint256 i = 0; i < _keys.length; i++) {
            textRecords[i].key = _keys[i];
            textRecords[i].value = TextResolver(resolver).text(_node, _keys[i]);
        }
    }

    function canonicalRecordsOfNode(bytes32 _node) public view returns (DefaultRecords memory canonicalRecords) {
        address resolver = registry.resolver(_node);

        canonicalRecords.name = NameResolver(resolver).name(_node);
        canonicalRecords.addr = AddrResolver(resolver).addr(_node);

        // string[] memory keys = new string[](2);
        // keys[0] = "rame";
        // keys[1] = "rame";
        (bool success, bytes memory data) = address(this).staticcall(
            abi.encodeWithSelector(this.textRecordsOfNode.selector, _node, defaultTextRecordsKeys)
        );
        if (success) {
            canonicalRecords.textRecords = abi.decode(data, (TextRecord[]));
        }
    }

    function metadataOfNode(bytes32 _node) public view returns (NodeMetadata memory metadata) {
        metadata.owner = registry.owner(_node);
        if (metadata.owner == address(0)) {
            return metadata;
        }

        metadata.resolver = registry.resolver(_node);
        if (metadata.resolver == address(0)) {
            return metadata;
        }

        metadata.canonicalRecords = canonicalRecordsOfNode(_node);
    }

    function nodesOfOwner(address _owner) public view returns (bytes32[] memory nodes) {
        uint256 balance = registry.balanceOf(_owner);
        nodes = new bytes32[](balance);

        for (uint256 i = 0; i < balance; i++) {
            uint256 nodeId = registry.tokenOfOwnerByIndex(_owner, i);
            nodes[i] = bytes32(nodeId);
        }
    }

    function namesOfOwner(address _owner) public view returns (string[] memory names) {
        bytes32[] memory nodes = nodesOfOwner(_owner);
        names = new string[](nodes.length);

        for (uint256 i = 0; i < nodes.length; i++) {
            uint256 nodeId = registry.tokenOfOwnerByIndex(_owner, i);
            if (nodeId == 0) {
                names[i] = "[root]";
                continue;
            }
            names[i] = namehashDB.lookup(bytes32(nodeId));
        }
    }
}
