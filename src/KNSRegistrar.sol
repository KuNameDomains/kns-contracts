// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import { NameRegistry } from "./interfaces/NameRegistry.sol";
import { NameRegistrar } from "./interfaces/NameRegistrar.sol";
import { NamehashDB } from "./interfaces/NamehashDB.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

error RegistrarNotLive();
error Unauthorized();
error UnavailableName();

/// @title KNS Registrar
/// @author Gilgames <gilgames@kuname.domains>
contract KNSRegistrar is NameRegistrar, Ownable {
    NameRegistry public registry;
    NamehashDB public namehashDB;
    bytes32 public rootNode;
    mapping(address => bool) public controllers;

    constructor(
        NameRegistry _registry,
        NamehashDB _namehashDB,
        bytes32 _rootNode
    ) {
        registry = _registry;
        namehashDB = _namehashDB;
        rootNode = _rootNode;
    }

    modifier onlyWhenLive() {
        if (registry.owner(rootNode) != address(this)) {
            revert RegistrarNotLive();
        }
        _;
    }

    modifier onlyController() {
        if (!controllers[msg.sender]) {
            revert Unauthorized();
        }
        _;
    }

    function addController(address controller) external override onlyOwner {
        controllers[controller] = true;
        emit ControllerAdded(controller);
    }

    function removeController(address controller) external override onlyOwner {
        controllers[controller] = false;
        emit ControllerRemoved(controller);
    }

    function setResolver(address resolver) external override onlyOwner {
        registry.setResolver(rootNode, resolver);
    }

    function setNamehashDB(NamehashDB _namehashDB) external onlyOwner {
        namehashDB = _namehashDB;
    }

    function available(string calldata name) public view override returns (bool) {
        bytes32 node = keccak256(abi.encodePacked(rootNode, keccak256(abi.encodePacked(name))));
        return !registry.recordExists(node);
    }

    function register(string calldata name, address owner) public onlyWhenLive onlyController returns (bytes32) {
        if (!available(name)) {
            revert UnavailableName();
        }

        bytes32 hashedName = keccak256(abi.encodePacked(name));
        registry.setSubnodeOwner(rootNode, hashedName, owner);

        namehashDB.store(rootNode, name);

        emit NameRegistered(hashedName, owner);

        return hashedName;
    }
}
