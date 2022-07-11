// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import { DSTestPlusPlus } from "./utils/DSTestPlusPlus.sol";
import "../src/KNSPriceOracle.sol";
import { IWitnetPriceRouter } from "witnet-solidity-bridge/contracts/interfaces/IWitnetPriceRouter.sol";
import { IWitnetPriceFeed } from "witnet-solidity-bridge/contracts/interfaces/IWitnetPriceFeed.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract KNSPriceOracleTest is DSTestPlusPlus {
    KNSPriceOracle priceOracle;
    IWitnetPriceRouter priceRouter = IWitnetPriceRouter(address(1));
    IWitnetPriceFeed priceFeed = IWitnetPriceFeed(address(2));
    address nftCollection = address(3);
    address alice = address(4);
    address bob = address(5);
    int256 kcsUSDTPrice = 20 * 10**6;

    struct NamePriceTestCase {
        string name;
        uint256 length;
        uint256 expectedBasePrice;
        uint256 expectedDiscountedPrice;
    }

    function setUp() public {
        vm.label(address(priceOracle), "PriceOracle");
        vm.label(address(priceRouter), "PriceRouter");
        vm.label(address(priceFeed), "PriceFeed");
        vm.label(nftCollection, "NFT");
        vm.label(alice, "Alice");
        vm.label(bob, "Bob");

        vm.mockCall(address(nftCollection), abi.encodeWithSelector(IERC721.balanceOf.selector, alice), abi.encode(0));
        vm.mockCall(address(nftCollection), abi.encodeWithSelector(IERC721.balanceOf.selector, bob), abi.encode(1));

        vm.mockCall(
            address(priceRouter),
            abi.encodeWithSelector(IWitnetPriceRouter.getPriceFeed.selector),
            abi.encode(address(priceFeed))
        );

        vm.mockCall(
            address(priceFeed),
            abi.encodeWithSelector(IWitnetPriceFeed.lastPrice.selector),
            abi.encode(kcsUSDTPrice)
        );

        priceOracle = new KNSPriceOracle(priceRouter);
    }

    function testNamePrice() public {
        NamePriceTestCase[8] memory tests = [
            NamePriceTestCase("tre", 3, 35 ether, 31.5 ether),
            NamePriceTestCase("four", 4, 10 ether, 8 ether),
            NamePriceTestCase("cinco", 5, 3.5 ether, 2.45 ether),
            NamePriceTestCase("133742", 6, 1 ether, 0.5 ether),
            NamePriceTestCase(unicode"你好好", 3, 35 ether, 31.5 ether),
            NamePriceTestCase(unicode"هيلو", 4, 10 ether, 8 ether),
            NamePriceTestCase(unicode"مرحبا", 5, 3.5 ether, 2.45 ether),
            NamePriceTestCase(unicode"Привет", 6, 1 ether, 0.5 ether)
        ];

        priceOracle.addEligibleCollection(nftCollection);
        for (uint256 i = 0; i < tests.length; i++) {
            assertEq(priceOracle.getNamePriceInKCSForBuyer(tests[i].name, alice), tests[i].expectedBasePrice);
            assertEq(priceOracle.getNamePriceInKCSForBuyer(tests[i].name, bob), tests[i].expectedDiscountedPrice);
        }
    }

    function testNamePriceBreakdown() public {
        priceOracle.addEligibleCollection(nftCollection);

        PriceBreakdown memory priceBreakdown = priceOracle.getNamePriceBreakdownForBuyer("four", alice);
        assertEq(priceBreakdown.basePrice, 10 ether);
        assertEq(priceBreakdown.discountedPrice, 8 ether);
        assertEq(priceBreakdown.finalPrice, 10 ether);
        assertFalse(priceBreakdown.isEligibleForDiscount);
    }

    function testNameTooShort() public {
        vm.expectRevert(NameTooShort.selector);
        priceOracle.getNamePriceInKCSForBuyer("", alice);
        vm.expectRevert(NameTooShort.selector);
        priceOracle.getNamePriceInKCSForBuyer("a", alice);
        vm.expectRevert(NameTooShort.selector);
        priceOracle.getNamePriceInKCSForBuyer("aa", alice);
        vm.expectRevert(NameTooShort.selector);
        priceOracle.getNamePriceInKCSForBuyer("", bob);
        vm.expectRevert(NameTooShort.selector);
        priceOracle.getNamePriceInKCSForBuyer("a", bob);
        vm.expectRevert(NameTooShort.selector);
        priceOracle.getNamePriceInKCSForBuyer("aa", bob);
    }

    function testAddEligibleCollection() public {
        priceOracle.addEligibleCollection(nftCollection);
        vm.expectRevert(CollectionAlreadyEligible.selector);
        priceOracle.addEligibleCollection(nftCollection);
        vm.startPrank(alice);
        vm.expectRevert("Ownable: caller is not the owner");
        priceOracle.addEligibleCollection(nftCollection);
        vm.stopPrank();
    }

    function testRemoveEligibleCollection() public {
        priceOracle.addEligibleCollection(nftCollection);
        priceOracle.removeEligibleCollection(nftCollection);
        vm.expectRevert(CollectionNotEligible.selector);
        priceOracle.removeEligibleCollection(nftCollection);
        vm.startPrank(alice);
        vm.expectRevert("Ownable: caller is not the owner");
        priceOracle.removeEligibleCollection(nftCollection);
        vm.stopPrank();
    }
}
