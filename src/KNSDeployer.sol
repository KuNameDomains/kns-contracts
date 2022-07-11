// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import { KNSRegistrar } from "./KNSRegistrar.sol";
import { KNSRegistry } from "./KNSRegistry.sol";
import { KNSPublicResolver, NameResolver } from "./KNSPublicResolver.sol";
import { KNSReverseRegistrar } from "./KNSReverseRegistrar.sol";
import { NamehashDB } from "./interfaces/NamehashDB.sol";

/// @title KNS Deployer
/// @author Gilgames <gilgames@kuname.domains>
contract KNSDeployer {
    bytes32 public constant TLD_LABEL = keccak256("kcc");
    bytes32 public constant RESOLVER_LABEL = keccak256("resolver");
    bytes32 public constant REVERSE_REGISTRAR_LABEL = keccak256("reverse");
    bytes32 public constant ADDR_LABEL = keccak256("addr");

    KNSRegistry public registry;
    KNSRegistrar public registrar;
    KNSReverseRegistrar public reverseRegistrar;
    KNSPublicResolver public publicResolver;
    NamehashDB public namehashDB;

    function namehash(bytes32 node, bytes32 label) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(node, label));
    }

    constructor(NamehashDB _namehashDB) {
        namehashDB = _namehashDB;
        registry = new KNSRegistry();
        publicResolver = new KNSPublicResolver(registry);

        bytes32 resolverNode = namehash(bytes32(0), RESOLVER_LABEL);

        registry.setSubnodeOwner(bytes32(0), RESOLVER_LABEL, address(this));
        registry.setResolver(resolverNode, address(publicResolver));
        publicResolver.setAddr(resolverNode, address(publicResolver));

        registrar = new KNSRegistrar(registry, namehashDB, namehash(bytes32(0), TLD_LABEL));
        bytes32 tldNode = registry.setSubnodeOwner(bytes32(0), TLD_LABEL, address(this));
        registry.setResolver(tldNode, address(publicResolver));
        registry.setOwner(tldNode, address(registrar));

        reverseRegistrar = new KNSReverseRegistrar(registry, NameResolver(address(publicResolver)));
        publicResolver.setController(address(reverseRegistrar), true);

        registry.setSubnodeOwner(bytes32(0), REVERSE_REGISTRAR_LABEL, address(this));
        registry.setSubnodeOwner(namehash(bytes32(0), REVERSE_REGISTRAR_LABEL), ADDR_LABEL, address(reverseRegistrar));

        registry.setSubnodeOwner(bytes32(0), RESOLVER_LABEL, msg.sender);
        registry.setSubnodeOwner(bytes32(0), REVERSE_REGISTRAR_LABEL, msg.sender);
        registry.setOwner(bytes32(0), msg.sender);

        registrar.transferOwnership(msg.sender);
        reverseRegistrar.transferOwnership(msg.sender);
        publicResolver.transferOwnership(msg.sender);
    }
}
