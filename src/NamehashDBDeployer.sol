// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import { OnChainNamehashDB } from "./OnChainNamehashDB.sol";
import { NamehashDB } from "./interfaces/NamehashDB.sol";

/// @title KNS NamehashDB Setup
/// @author Gilgames <gilgames@kuname.domains>
contract NamehashDBDeployer {
    NamehashDB public immutable namehashDB;

    function namehash(bytes32 node, bytes32 label) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(node, label));
    }

    constructor() {
        namehashDB = new OnChainNamehashDB();
        namehashDB.store(bytes32(0), "kcc");
        namehashDB.store(bytes32(0), "resolver");
        namehashDB.store(bytes32(0), "reverse");
        namehashDB.store(namehash(bytes32(0), "reverse"), "addr");
    }
}
