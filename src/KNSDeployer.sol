// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import { KNSRegistrar } from "./KNSRegistrar.sol";
import { KNSRegistry } from "./KNSRegistry.sol";
import { KNSPublicResolver } from "./KNSPublicResolver.sol";
import { NameResolver, KNSReverseRegistrar } from "./KNSReverseRegistrar.sol";

/// @title KNS Deployer
/// @author Gilgames <gilgames@kuname.domains>
contract KNSDeployer {
    bytes32 public constant TLD_LABEL = keccak256("kcc");
    bytes32 public constant RESOLVER_LABEL = keccak256("resolver");
    bytes32 public constant REVERSE_REGISTRAR_LABEL = keccak256("reverse");
    bytes32 public constant ADDR_LABEL = keccak256("addr");

    KNSRegistry public kns;
    KNSRegistrar public registrar;
    KNSReverseRegistrar public reverseRegistrar;
    KNSPublicResolver public publicResolver;

    function namehash(bytes32 node, bytes32 label) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(node, label));
    }

    constructor() {
        kns = new KNSRegistry();
        publicResolver = new KNSPublicResolver(kns);

        bytes32 resolverNode = namehash(bytes32(0), RESOLVER_LABEL);

        kns.setSubnodeOwner(bytes32(0), RESOLVER_LABEL, address(this));
        kns.setResolver(resolverNode, address(publicResolver));
        publicResolver.setAddr(resolverNode, address(publicResolver));

        registrar = new KNSRegistrar(kns, namehash(bytes32(0), TLD_LABEL));
        kns.setSubnodeOwner(bytes32(0), TLD_LABEL, address(registrar));

        reverseRegistrar = new KNSReverseRegistrar(kns, NameResolver(address(publicResolver)));

        kns.setSubnodeOwner(bytes32(0), REVERSE_REGISTRAR_LABEL, address(this));
        kns.setSubnodeOwner(namehash(bytes32(0), REVERSE_REGISTRAR_LABEL), ADDR_LABEL, address(reverseRegistrar));

        kns.setSubnodeOwner(bytes32(0), RESOLVER_LABEL, msg.sender);
        kns.setSubnodeOwner(bytes32(0), REVERSE_REGISTRAR_LABEL, msg.sender);
        kns.setOwner(bytes32(0), msg.sender);
    }
}
