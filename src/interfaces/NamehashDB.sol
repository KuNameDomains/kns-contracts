// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

interface NamehashDB {
    /**
     * @dev Stores the hash and the full original name of a subnode from
     *      the hash of its node and the subnode label.
     * @param node The hash of the node parent of the subnode.
     * @param label The name of the subnode to be stored.
     */
    function store(bytes32 node, string calldata label) external;

    /**
     * @dev Looks up the full original name of a node.
     * @param nodehash The hash of the node to lookup.
     * @return An empty string if the node is not in the DB, the name otherwise.
     */
    function lookup(bytes32 nodehash) external view returns (string memory);
}
