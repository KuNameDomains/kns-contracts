// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import { KNSRegistrarController } from "./KNSRegistrarController.sol";
import { KNSRegistrar } from "./KNSRegistrar.sol";
import { KNSPublicResolver } from "./KNSPublicResolver.sol";
import { KNSReverseRegistrar } from "./KNSReverseRegistrar.sol";

contract KNSRegistrarControllerDeployer {
    KNSRegistrarController public immutable controller;

    constructor(
        KNSRegistrar _registrar,
        KNSReverseRegistrar _reverseRegistrar,
        KNSPublicResolver _publicResolver
    ) {
        controller = new KNSRegistrarController(_registrar, _reverseRegistrar);
        _registrar.addController(address(controller));
        _reverseRegistrar.setController(address(controller), true);
        _publicResolver.setController(address(controller), true);
    }
}
