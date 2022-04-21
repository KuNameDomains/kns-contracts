// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import { KNSRegistry } from "./KNSRegistry.sol";
import "@ensdomains/ens-contracts/contracts/registry/IReverseRegistrar.sol";
import "@ensdomains/ens-contracts/contracts/resolvers/profiles/NameResolver.sol";
import "@ensdomains/ens-contracts/contracts/root/Controllable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

bytes32 constant lookup = 0x3031323334353637383961626364656600000000000000000000000000000000;

bytes32 constant ADDR_REVERSE_NODE = 0x91d1777781884d03a6757a803996e38de2a42967fb37eeaca72729271025a9e2; // namehash('addr.reverse')

/// @title KNS Reverse Registrar
/// @author Gilgames <gilgames@kuname.domains>
/// @notice This contract is a derivative work of the ENS Reverse Registrar.
///         The only difference is that the original contract supported a name
///         wrapping system to treat names like NFTs, functionality that KNS
///         offers by default through the KNS Registry.
contract KNSReverseRegistrar is Ownable, Controllable, IReverseRegistrar {
    KNSRegistry public immutable registry;
    NameResolver public defaultResolver;

    event ReverseClaimed(address indexed addr, bytes32 indexed node);

    /**
     * @dev Constructor
     * @param _registry The KNS registry.
     * @param _defaultResolver The default resolver that will be set for new
     *                         records created by the reverse registrar.
     */
    constructor(KNSRegistry _registry, NameResolver _defaultResolver) {
        registry = _registry;
        defaultResolver = _defaultResolver;

        // Assign ownership of the reverse record to our deployer
        KNSReverseRegistrar oldRegistrar = KNSReverseRegistrar(registry.owner(ADDR_REVERSE_NODE));
        if (address(oldRegistrar) != address(0x0)) {
            oldRegistrar.claim(msg.sender);
        }
    }

    modifier authorised(address addr) {
        require(
            addr == msg.sender ||
                controllers[msg.sender] ||
                registry.isApprovedForAll(addr, msg.sender) ||
                ownsContract(addr),
            "ReverseRegistrar: Caller is not a controller or authorised by address or the address itself"
        );
        _;
    }

    function setDefaultResolver(address resolver) public override onlyOwner {
        require(address(resolver) != address(0), "ReverseRegistrar: Resolver address must not be 0");
        defaultResolver = NameResolver(resolver);
    }

    /**
     * @dev Transfers ownership of the reverse KNS record associated with the
     *      calling account.
     * @param owner The address to set as the owner of the reverse record in KNS.
     * @return The KNS node hash of the reverse record.
     */
    function claim(address owner) public override returns (bytes32) {
        return claimForAddr(msg.sender, owner, address(defaultResolver));
    }

    /**
     * @dev Transfers ownership of the reverse KNS record associated with the
     *      calling account.
     * @param addr The reverse record to set
     * @param owner The address to set as the owner of the reverse record in KNS.
     * @return The KNS node hash of the reverse record.
     */
    function claimForAddr(
        address addr,
        address owner,
        address resolver
    ) public override authorised(addr) returns (bytes32) {
        bytes32 labelHash = sha3HexAddress(addr);
        bytes32 reverseNode = keccak256(abi.encodePacked(ADDR_REVERSE_NODE, labelHash));
        emit ReverseClaimed(addr, reverseNode);
        registry.setSubnodeRecord(ADDR_REVERSE_NODE, labelHash, owner, resolver, 0);
        return reverseNode;
    }

    /**
     * @dev Transfers ownership of the reverse KNS record associated with the
     *      calling account.
     * @param owner The address to set as the owner of the reverse record in KNS.
     * @param resolver The address of the resolver to set; 0 to leave unchanged.
     * @return The KNS node hash of the reverse record.
     */
    function claimWithResolver(address owner, address resolver) public override returns (bytes32) {
        return claimForAddr(msg.sender, owner, resolver);
    }

    /**
     * @dev Sets the `name()` record for the reverse KNS record associated with
     * the calling account. First updates the resolver to the default reverse
     * resolver if necessary.
     * @param name The name to set for this address.
     * @return The KNS node hash of the reverse record.
     */
    function setName(string memory name) public override returns (bytes32) {
        return setNameForAddr(msg.sender, msg.sender, address(defaultResolver), name);
    }

    /**
     * @dev Sets the `name()` record for the reverse KNS record associated with
     * the account provided. First updates the resolver to the default reverse
     * resolver if necessary.
     * Only callable by controllers and authorised users
     * @param addr The reverse record to set
     * @param owner The owner of the reverse node
     * @param name The name to set for this address.
     * @return The KNS node hash of the reverse record.
     */
    function setNameForAddr(
        address addr,
        address owner,
        address resolver,
        string memory name
    ) public override returns (bytes32) {
        bytes32 _node = claimForAddr(addr, owner, resolver);
        NameResolver(resolver).setName(_node, name);
        return _node;
    }

    /**
     * @dev Returns the node hash for a given account's reverse records.
     * @param addr The address to hash
     * @return The KNS node hash.
     */
    function node(address addr) public pure override returns (bytes32) {
        return keccak256(abi.encodePacked(ADDR_REVERSE_NODE, sha3HexAddress(addr)));
    }

    /**
     * @dev An optimised function to compute the sha3 of the lower-case
     *      hexadecimal representation of an Ethereum address.
     * @param addr The address to hash
     * @return ret The SHA3 hash of the lower-case hexadecimal encoding of the
     *         input address.
     */
    function sha3HexAddress(address addr) private pure returns (bytes32 ret) {
        assembly {
            for {
                let i := 40
            } gt(i, 0) {

            } {
                i := sub(i, 1)
                mstore8(i, byte(and(addr, 0xf), lookup))
                addr := div(addr, 0x10)
                i := sub(i, 1)
                mstore8(i, byte(and(addr, 0xf), lookup))
                addr := div(addr, 0x10)
            }

            ret := keccak256(0, 40)
        }
    }

    function ownsContract(address addr) internal view returns (bool) {
        try Ownable(addr).owner() returns (address owner) {
            return owner == msg.sender;
        } catch {
            return false;
        }
    }
}
