// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { Strings } from "./libraries/Strings.sol";
import { IWitnetPriceRouter, IERC165 } from "witnet-solidity-bridge/contracts/interfaces/IWitnetPriceRouter.sol";
import { IWitnetPriceFeed } from "witnet-solidity-bridge/contracts/interfaces/IWitnetPriceFeed.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

error NameTooShort();
error CollectionAlreadyEligible();
error CollectionNotEligible();

struct PriceBreakdown {
    bool isEligibleForDiscount;
    uint256 basePrice;
    uint256 discountedPrice;
    uint256 finalPrice;
}

contract KNSPriceOracle is Ownable {
    using Strings for string;

    IWitnetPriceRouter public immutable witnetPriceRouter;
    bytes32 public immutable kcsUSDTFeedID;
    IWitnetPriceFeed public kcsUSDTPriceFeed;
    address[] public nftCollectionsEligibleForDiscount;

    constructor(IWitnetPriceRouter _witnetPriceRouter) {
        witnetPriceRouter = _witnetPriceRouter;
        kcsUSDTFeedID = bytes32(0x31debffc453c5d04a78431e7bc28098c606d2bbeea22f10a35809924a201a977);
        updateKCSUSDTPriceFeed();
    }

    /// Detects if the WitnetPriceRouter is now pointing to a different IWitnetPriceFeed implementation:
    function updateKCSUSDTPriceFeed() public {
        IERC165 _newPriceFeed = witnetPriceRouter.getPriceFeed(kcsUSDTFeedID);
        if (address(_newPriceFeed) != address(0)) {
            kcsUSDTPriceFeed = IWitnetPriceFeed(address(_newPriceFeed));
        }
    }

    function getNameBasePriceInUSD(string calldata name) public pure returns (uint256 price) {
        uint256 length = name.strlen();

        if (length < 3) {
            revert NameTooShort();
        } else if (length == 3) {
            price = 700;
        } else if (length == 4) {
            price = 200;
        } else if (length == 5) {
            price = 70;
        } else if (length >= 6) {
            price = 20;
        }

        price = price * 10**6;
    }

    function getNameDiscountedPriceInUSD(string calldata name) public pure returns (uint256 price) {
        uint256 length = name.strlen();

        if (length < 3) {
            revert NameTooShort();
        } else if (length == 3) {
            price = 630;
        } else if (length == 4) {
            price = 160;
        } else if (length == 5) {
            price = 49;
        } else if (length >= 6) {
            price = 10;
        }

        price = price * 10**6;
    }

    function isEligibleForDiscount(address buyer) public view returns (bool) {
        for (uint256 i = 0; i < nftCollectionsEligibleForDiscount.length; i++) {
            if (IERC721(nftCollectionsEligibleForDiscount[i]).balanceOf(buyer) > 0) {
                return true;
            }
        }

        return false;
    }

    function getNameBasePriceInKCS(string calldata name) public view returns (uint256 price) {
        uint256 nameUSDPrice = getNameBasePriceInUSD(name);
        int256 kcsUSDTPrice = kcsUSDTPriceFeed.lastPrice();

        return (nameUSDPrice * 10**18) / uint256(kcsUSDTPrice);
    }

    function getNameDiscountedPriceInKCS(string calldata name) public view returns (uint256 price) {
        uint256 nameUSDPrice = getNameDiscountedPriceInUSD(name);
        int256 kcsUSDTPrice = kcsUSDTPriceFeed.lastPrice();

        return (nameUSDPrice * 10**18) / uint256(kcsUSDTPrice);
    }

    function getNamePriceInKCSForBuyer(string calldata name, address buyer) public view returns (uint256 price) {
        uint256 nameUSDPrice;
        int256 kcsUSDTPrice = kcsUSDTPriceFeed.lastPrice();

        if (isEligibleForDiscount(buyer)) {
            nameUSDPrice = getNameDiscountedPriceInUSD(name);
        } else {
            nameUSDPrice = getNameBasePriceInUSD(name);
        }

        return (nameUSDPrice * 10**18) / uint256(kcsUSDTPrice);
    }

    function getNamePriceBreakdownForBuyer(string calldata name, address _buyer)
        public
        view
        returns (PriceBreakdown memory priceBreakdown)
    {
        priceBreakdown.isEligibleForDiscount = isEligibleForDiscount(_buyer);
        priceBreakdown.basePrice = getNameBasePriceInKCS(name);
        priceBreakdown.discountedPrice = getNameDiscountedPriceInKCS(name);
        priceBreakdown.finalPrice = getNamePriceInKCSForBuyer(name, _buyer);
    }

    function addEligibleCollection(address collection) public onlyOwner {
        for (uint256 i = 0; i < nftCollectionsEligibleForDiscount.length; i++) {
            if (nftCollectionsEligibleForDiscount[i] == collection) {
                revert CollectionAlreadyEligible();
            }
        }

        nftCollectionsEligibleForDiscount.push(collection);
    }

    function removeEligibleCollection(address collection) public onlyOwner {
        for (uint256 i = 0; i < nftCollectionsEligibleForDiscount.length; i++) {
            if (nftCollectionsEligibleForDiscount[i] == collection) {
                nftCollectionsEligibleForDiscount[i] = nftCollectionsEligibleForDiscount[
                    nftCollectionsEligibleForDiscount.length - 1
                ];
                nftCollectionsEligibleForDiscount.pop();
                return;
            }
        }

        revert CollectionNotEligible();
    }
}
