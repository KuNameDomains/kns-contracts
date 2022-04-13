// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

error Unauthorized();

/// @title KNS Registry
/// @author Gilgames <gilgames@kuname.domains>
/// @notice This contract is inspired by the ENS registry, but it is designed
///         be compatible with the ERC721 standard out-of-the-box.
contract KNSRegistry is ERC721, ERC721Enumerable {
    // Logged when the owner of a node assigns a new owner to a subnode.
    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);

    // Logged when the resolver for a node changes.
    event NewResolver(bytes32 indexed node, address resolver);

    // Logged when the TTL of a node changes
    event NewTTL(bytes32 indexed node, uint64 ttl);

    struct Record {
        address resolver;
        uint64 ttl;
    }

    mapping(bytes32 => Record) records;

    // Permits modifications only by the owner of the specified node.
    modifier authorised(bytes32 node) {
        if (!_isApprovedOrOwner(_msgSender(), uint256(node))) {
            revert Unauthorized();
        }
        _;
    }

    /**
     * @dev Constructs a new KNS registry.
     */
    constructor() ERC721("KCC Name Service", "KNS") {
        _mint(_msgSender(), uint256(0x0));
    }

    /**
     * @dev Sets the record for a node.
     * @param node The node to update.
     * @param _owner The address of the new owner.
     * @param _resolver The address of the resolver.
     * @param _ttl The TTL in seconds.
     */
    function setRecord(
        bytes32 node,
        address _owner,
        address _resolver,
        uint64 _ttl
    ) external virtual {
        setOwner(node, _owner);
        _setResolverAndTTL(node, _resolver, _ttl);
    }

    /**
     * @dev Sets the record for a subnode.
     * @param node The parent node.
     * @param label The hash of the label specifying the subnode.
     * @param _owner The address of the new owner.
     * @param _resolver The address of the resolver.
     * @param _ttl The TTL in seconds.
     */
    function setSubnodeRecord(
        bytes32 node,
        bytes32 label,
        address _owner,
        address _resolver,
        uint64 _ttl
    ) external virtual {
        bytes32 subnode = setSubnodeOwner(node, label, _owner);
        _setResolverAndTTL(subnode, _resolver, _ttl);
    }

    /**
     * @dev Transfers ownership of a node to a new address. May only be called by the current owner of the node.
     * @param node The node to transfer ownership of.
     * @param _owner The address of the new owner.
     */
    function setOwner(bytes32 node, address _owner) public virtual authorised(node) {
        uint256 nodeID = uint256(node);
        if (_owner == address(0)) {
            _burn(nodeID);
        } else {
            _transfer(owner(node), _owner, nodeID);
        }
    }

    /**
     * @dev Transfers ownership of a subnode keccak256(node, label) to a new address. May only be called by the owner of the parent node.
     * @param node The parent node.
     * @param label The hash of the label specifying the subnode.
     * @param _owner The address of the new owner.
     */
    function setSubnodeOwner(
        bytes32 node,
        bytes32 label,
        address _owner
    ) public virtual authorised(node) returns (bytes32) {
        bytes32 subnode = keccak256(abi.encodePacked(node, label));
        uint256 subnodeID = uint256(subnode);
        // it will revert if node doesn't exists and _owner is 0
        if (!_exists(subnodeID)) {
            _mint(_owner, subnodeID);
        } else if (_owner == address(0)) {
            _burn(subnodeID);
        } else {
            _transfer(owner(subnode), _owner, subnodeID);
        }
        emit NewOwner(node, label, _owner);
        return subnode;
    }

    /**
     * @dev Sets the resolver address for the specified node.
     * @param node The node to update.
     * @param _resolver The address of the resolver.
     */
    function setResolver(bytes32 node, address _resolver) public virtual authorised(node) {
        emit NewResolver(node, _resolver);
        records[node].resolver = _resolver;
    }

    /**
     * @dev Sets the TTL for the specified node.
     * @param node The node to update.
     * @param _ttl The TTL in seconds.
     */
    function setTTL(bytes32 node, uint64 _ttl) public virtual authorised(node) {
        emit NewTTL(node, _ttl);
        records[node].ttl = _ttl;
    }

    /**
     * @dev Returns the address that owns the specified node.
     * @param node The specified node.
     * @return address of the owner.
     */
    function owner(bytes32 node) public view virtual returns (address) {
        uint256 nodeID = uint256(node);

        // ownerOf throws when the owner is the zero address, but we
        // want to return it instead, in order to comply with ENS
        if (!_exists(nodeID)) {
            return address(0x0);
        }

        address addr = ownerOf(nodeID);
        if (addr == address(this)) {
            return address(0x0);
        }

        return addr;
    }

    /**
     * @dev Returns the address of the resolver for the specified node.
     * @param node The specified node.
     * @return address of the resolver.
     */
    function resolver(bytes32 node) public view virtual returns (address) {
        return records[node].resolver;
    }

    /**
     * @dev Returns the TTL of a node, and any records associated with it.
     * @param node The specified node.
     * @return ttl of the node.
     */
    function ttl(bytes32 node) public view virtual returns (uint64) {
        return records[node].ttl;
    }

    /**
     * @dev Returns whether a record has been imported to the registry.
     * @param node The specified node.
     * @return Bool if record exists
     */
    function recordExists(bytes32 node) public view virtual returns (bool) {
        return _exists(uint256(node));
    }

    function _setResolverAndTTL(
        bytes32 node,
        address _resolver,
        uint64 _ttl
    ) internal {
        if (_resolver != records[node].resolver) {
            records[node].resolver = _resolver;
            emit NewResolver(node, _resolver);
        }

        if (_ttl != records[node].ttl) {
            records[node].ttl = _ttl;
            emit NewTTL(node, _ttl);
        }
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
