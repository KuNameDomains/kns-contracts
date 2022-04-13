// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import { KNSRegistry } from "./KNSRegistry.sol";
import "@ensdomains/ens-contracts/contracts/registry/ENS.sol";

/// @title KNS Registrar
/// @author Gilgames <gilgames@kuname.domains>
contract KNSRegistrar {
    KNSRegistry registry;
    bytes32 rootNode;

    modifier only_owner(bytes32 label) {
        address currentOwner = registry.owner(keccak256(abi.encodePacked(rootNode, label)));
        require(currentOwner == address(0x0) || currentOwner == msg.sender);
        _;
    }

    /**
     * Constructor.
     * @param _registry The address of the KNS registry.
     * @param node The node that this registrar administers.
     */
    constructor(KNSRegistry _registry, bytes32 node) {
        registry = _registry;
        rootNode = node;
    }

    /**
     * Register a name, or change the owner of an existing registration.
     * @param label The hash of the label to register.
     * @param owner The address of the new owner.
     */
    function register(bytes32 label, address owner) public only_owner(label) {
        registry.setSubnodeOwner(rootNode, label, owner);
    }
}
