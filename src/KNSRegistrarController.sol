// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import { NameRegistrar } from "./interfaces/NameRegistrar.sol";
import { Strings } from "./libraries/Strings.sol";
import "../src/KNSPriceOracle.sol";
import { AddrResolver } from "@ensdomains/ens-contracts/contracts/resolvers/profiles/AddrResolver.sol";
import { IReverseRegistrar } from "@ensdomains/ens-contracts/contracts/registry/IReverseRegistrar.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

error UnavailableName();
error NotEnoughKCSProvided();
error ControllerNotLive();

contract KNSRegistrarController is Ownable {
    using Strings for string;

    NameRegistrar public immutable registrar;
    IReverseRegistrar public immutable reverseRegistrar;
    KNSPriceOracle public priceOracle;

    event NameRegistered(string name, bytes32 indexed label, address indexed owner);

    constructor(NameRegistrar _registrar, IReverseRegistrar _reverseRegistrar) {
        registrar = _registrar;
        reverseRegistrar = _reverseRegistrar;
    }

    function setPriceOracle(address _priceOracle) public onlyOwner {
        priceOracle = KNSPriceOracle(_priceOracle);
    }

    function valid(string memory name) public pure returns (bool) {
        return name.strlen() >= 0;
    }

    function available(string memory name) public view returns (bool) {
        return valid(name) && registrar.available(name);
    }

    function register(
        string calldata name,
        address _owner,
        address resolver,
        address addr,
        bool reverseRecord
    ) public payable {
        if (address(priceOracle) == address(0)) {
            revert ControllerNotLive();
        }

        if (!available(name)) {
            revert UnavailableName();
        }

        uint256 price = priceOracle.getNamePriceInKCSForBuyer(name, msg.sender);
        if (owner() == msg.sender) {
            price = 0;
        }

        if (msg.value < price) {
            revert NotEnoughKCSProvided();
        }

        bytes32 hashedName;
        if (resolver != address(0)) {
            // We temporarily set this contract as the owner to give it
            // permission to set up the resolver.
            hashedName = registrar.register(name, address(this));

            bytes32 node = keccak256(abi.encodePacked(registrar.tldNode(), hashedName));
            registrar.registry().setResolver(node, resolver);

            if (addr != address(0)) {
                AddrResolver(resolver).setAddr(node, addr);
            }

            if (reverseRecord) {
                _setReverseRecord(name, resolver, msg.sender);
            }

            registrar.registry().transferFrom(address(this), _owner, uint256(node));
        } else {
            require(addr == address(0));
            require(reverseRecord == false);
            hashedName = registrar.register(name, _owner);
        }

        emit NameRegistered(name, hashedName, _owner);

        payable(owner()).transfer(price);
        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }
    }

    function withdraw() public {
        payable(owner()).transfer(address(this).balance);
    }

    function _setReverseRecord(
        string calldata name,
        address resolver,
        address owner
    ) internal {
        reverseRegistrar.setNameForAddr(msg.sender, owner, resolver, string(abi.encodePacked(name, ".kcc")));
    }
}
