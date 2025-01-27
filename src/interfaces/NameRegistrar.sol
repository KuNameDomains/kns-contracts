// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import { NameRegistry } from "./NameRegistry.sol";

interface NameRegistrar {
    /**
     * @dev Emitted when a new controller is added.
     */
    event ControllerAdded(address indexed controller);

    /**
     * @dev Emitted when a controller is removed.
     */
    event ControllerRemoved(address indexed controller);

    /**
     * @dev Emitted upon name registration.
     */
    event NameRegistered(bytes32 indexed hashedName, address indexed owner);

    /**
     * @dev Adds a controller that can register names.
     */
    function registry() external view returns (NameRegistry);

    /**
     * @dev Adds a controller that can register names.
     */
    function tldNode() external view returns (bytes32);

    /**
     * @dev Adds a controller that can register names.
     */
    function addController(address controller) external;

    /**
     * @dev Removes a previously added controller.
     */
    function removeController(address controller) external;

    /**
     * @dev Sets the resolver for the domain that this registrar manages.
     */
    function setResolver(address resolver) external;

    /**
     * @dev Returns true iff the specified name is available for registration.
     */
    function available(string calldata name) external view returns (bool);

    /**
     * @dev Registers a name.
     */
    function register(string calldata name, address owner) external returns (bytes32 hashedName);
}
