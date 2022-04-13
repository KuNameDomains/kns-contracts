// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import { NamehashDB } from "./NamehashDB.sol";

/// @title On-Chain Namehash Database
/// @author Gilgames <gilgames@kuname.domains>
/// @notice A simple on-chain DB to store and lookup hashed KNS names.
contract OnChainNamehashDB is NamehashDB {
    mapping(bytes32 => string) private names;
    mapping(bytes32 => bool) private exists;

    function namehash(bytes32 node, bytes32 label) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(node, label));
    }

    function _store(bytes32 node, string memory name) private {
        names[node] = name;
        exists[node] = true;
    }

    function store(bytes32 node, string calldata label) external {
        bytes32 subnode = namehash(node, keccak256(abi.encodePacked(label)));

        // if node is 0 then label is a tld, store it
        if (node == bytes32(0)) {
            _store(subnode, label);
            return;
        }

        // if parent node doesn't exist in the db, do nothing
        if (exists[node] == false) {
            return;
        }

        // if subnode already exists in db, do nothing
        if (bytes(names[subnode]).length != 0) {
            return;
        }

        _store(subnode, string(abi.encodePacked(label, ".", names[node])));
    }

    function lookup(bytes32 nodehash) external view returns (string memory) {
        return names[nodehash];
    }
}
