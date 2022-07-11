// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import { DSTestPlusPlus } from "./utils/DSTestPlusPlus.sol";
import { NamehashDBDeployer } from "../src/NamehashDBDeployer.sol";
import { KNSDeployer } from "../src/KNSDeployer.sol";
import { NamehashDB } from "../src/interfaces/NamehashDB.sol";
import { NameRegistrar } from "../src/interfaces/NameRegistrar.sol";
import { KNSRegistrarController } from "../src/KNSRegistrarController.sol";
import { KNSRegistrarControllerDeployer } from "../src/KNSRegistrarControllerDeployer.sol";
import { KNSPublicResolver } from "../src/KNSPublicResolver.sol";
import { KNSReverseRegistrar } from "../src/KNSReverseRegistrar.sol";
import { KNSPriceOracle } from "../src/KNSPriceOracle.sol";

contract KNSRegistrarControllerTest is DSTestPlusPlus {
    NameRegistrar registrar;
    KNSReverseRegistrar reverseRegistrar;
    KNSPublicResolver resolver;
    KNSRegistrarController controller;
    address priceOracle = address(1);

    function setUp() public {
        NamehashDB namehashDB = (new NamehashDBDeployer()).namehashDB();
        KNSDeployer deployer = new KNSDeployer(namehashDB);
        registrar = deployer.registrar();
        reverseRegistrar = deployer.reverseRegistrar();
        resolver = deployer.publicResolver();
        controller = new KNSRegistrarController(registrar, reverseRegistrar);

        vm.mockCall(
            priceOracle,
            abi.encodeWithSelector(KNSPriceOracle.getNamePriceInKCSForBuyer.selector),
            abi.encode(1 ether)
        );

        controller.setPriceOracle(priceOracle);
        registrar.addController(address(controller));
        reverseRegistrar.setController(address(controller), true);
        resolver.setController(address(controller), true);
    }

    function testRegistration(string calldata name) public {
        // vm.mockCall(
        //     address(registry),
        //     abi.encodeWithSelector(NameRegistry.owner.selector, rootNode),
        //     abi.encode(address(this))
        // );

        // vm.expectRevert(RegistrarNotLive.selector);
        vm.deal(address(2), 1 ether);
        vm.startPrank(address(2));
        controller.register{ value: 1 ether }(name, address(this), address(resolver), address(this), true);
    }

    receive() external payable {}
}
