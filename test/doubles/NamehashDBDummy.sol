// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import { NamehashDB } from "../../src/interfaces/NamehashDB.sol";

error Unimplemented();

contract NamehashDBDummy is NamehashDB {
    function store(bytes32 node, string calldata label) external virtual override {}

    function lookup(bytes32 nodehash) external view virtual override returns (string memory) {}
}
