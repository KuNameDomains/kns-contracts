// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import { DSTestPlusPlus } from "./utils/DSTestPlusPlus.sol";
import { NamehashDBDeployer } from "../src/NamehashDBDeployer.sol";
import { KNSDeployer } from "../src/KNSDeployer.sol";
import { NamehashDB } from "../src/interfaces/NamehashDB.sol";
import { NameRegistrar } from "../src/interfaces/NameRegistrar.sol";
import { KNSRegistrarController } from "../src/KNSRegistrarController.sol";
import { KNSPublicResolver } from "../src/KNSPublicResolver.sol";
import { IReverseRegistrar } from "@ensdomains/ens-contracts/contracts/registry/IReverseRegistrar.sol";

contract KNSRegistrarControllerTest is DSTestPlusPlus {
    NameRegistrar registrar;
    IReverseRegistrar reverseRegistrar;
    KNSPublicResolver resolver;
    KNSRegistrarController controller;

    function setUp() public {
        NamehashDB namehashDB = (new NamehashDBDeployer()).namehashDB();
        KNSDeployer deployer = new KNSDeployer(namehashDB);
        registrar = deployer.registrar();
        reverseRegistrar = deployer.reverseRegistrar();
        resolver = deployer.publicResolver();
        controller = deployer.controller();
    }

    function testRegistration(string calldata name) public {
        // vm.mockCall(
        //     address(registry),
        //     abi.encodeWithSelector(NameRegistry.owner.selector, rootNode),
        //     abi.encode(address(this))
        // );

        // vm.expectRevert(RegistrarNotLive.selector);
        controller.register(name, address(this), address(resolver), address(this), true);
    }
}
