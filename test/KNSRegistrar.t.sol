// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import { DSTestPlusPlus } from "./utils/DSTestPlusPlus.sol";
import { KNSRegistrar, Unauthorized, RegistrarNotLive, UnavailableName } from "../src/KNSRegistrar.sol";
import { NameRegistryDummy } from "./doubles/NameRegistryDummy.sol";
import { AcceptiveRegistryStub } from "./doubles/AcceptiveRegistryStub.sol";
import { RejectiveRegistryStub } from "./doubles/RejectiveRegistryStub.sol";
import { NamehashDBDummy } from "./doubles/NamehashDBDummy.sol";
import { NameRegistry } from "../src/interfaces/NameRegistry.sol";
import { NamehashDB } from "../src/interfaces/NamehashDB.sol";

contract KNSRegistrarTest is DSTestPlusPlus {
    NameRegistry dummyRegistry;
    AcceptiveRegistryStub acceptiveRegistry;
    RejectiveRegistryStub rejectiveRegistry;
    NamehashDB namehashDB;

    function setUp() public {
        dummyRegistry = new NameRegistryDummy();
        acceptiveRegistry = new AcceptiveRegistryStub();
        rejectiveRegistry = new RejectiveRegistryStub();
        namehashDB = new NamehashDBDummy();
    }

    function testNameAvailable(string calldata name) public {
        KNSRegistrar registrar = new KNSRegistrar(acceptiveRegistry, namehashDB, "");
        assertTrue(registrar.available(name));
    }

    function testNameNotAvailable(string calldata name) public {
        NameRegistry registry = rejectiveRegistry;
        KNSRegistrar registrar = new KNSRegistrar(registry, namehashDB, "");
        assertFalse(registrar.available(name));

        vm.mockCall(
            address(registry),
            abi.encodeWithSelector(NameRegistry.owner.selector, bytes32("")),
            abi.encode(registrar)
        );

        registrar.addController(address(this));
        vm.expectRevert(UnavailableName.selector);
        registrar.register(name, address(this));
    }

    function testAuthorizedNameRegistration(string calldata name, bytes32 rootNode) public {
        NameRegistry registry = acceptiveRegistry;
        KNSRegistrar registrar = new KNSRegistrar(registry, namehashDB, rootNode);
        bytes32 hashedName = keccak256(abi.encodePacked(name));

        vm.mockCall(
            address(registry),
            abi.encodeWithSelector(NameRegistry.owner.selector, rootNode),
            abi.encode(registrar)
        );

        vm.expectRevert(Unauthorized.selector);
        registrar.register(name, address(this));

        registrar.addController(address(this));
        assertEq(registrar.register(name, address(this)), hashedName);

        registrar.removeController(address(this));
        vm.expectRevert(Unauthorized.selector);
        registrar.register(name, address(this));
    }

    function testUnauthorizedNameRegistration(string calldata name, bytes32 rootNode) public {
        NameRegistry registry = rejectiveRegistry;
        KNSRegistrar registrar = new KNSRegistrar(registry, namehashDB, rootNode);

        vm.mockCall(
            address(registry),
            abi.encodeWithSelector(NameRegistry.owner.selector, rootNode),
            abi.encode(registrar)
        );

        vm.expectRevert(Unauthorized.selector);
        registrar.register(name, address(this));
    }

    function testNotLiveNameRegistration(string calldata name, bytes32 rootNode) public {
        NameRegistry registry = dummyRegistry;
        KNSRegistrar registrar = new KNSRegistrar(registry, namehashDB, rootNode);
        dummyRegistry.getApproved(1);

        vm.mockCall(
            address(registry),
            abi.encodeWithSelector(NameRegistry.owner.selector, rootNode),
            abi.encode(address(this))
        );

        vm.expectRevert(RegistrarNotLive.selector);
        registrar.register(name, address(this));
    }

    function testAuthorizedControllerRegistration(address controller) public {
        KNSRegistrar registrar = new KNSRegistrar(dummyRegistry, namehashDB, "");
        assertFalse(registrar.controllers(controller));

        registrar.addController(controller);
        assertTrue(registrar.controllers(controller));

        registrar.removeController(controller);
        assertFalse(registrar.controllers(controller));
    }

    function testUnauthorizedControllerRegistration(address badActor) public {
        NameRegistry registry = dummyRegistry;
        vm.assume(badActor != address(0));
        vm.assume(badActor != address(dummyRegistry));
        vm.assume(badActor != address(this));

        KNSRegistrar registrar = new KNSRegistrar(registry, namehashDB, "");
        assertFalse(registrar.controllers(badActor));

        vm.startPrank(badActor);

        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        registrar.addController(badActor);

        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        registrar.removeController(badActor);
    }
}
