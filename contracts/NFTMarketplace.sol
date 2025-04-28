// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title NFTMarketplace
 * @notice A simple marketplace for ERC-721 and ERC-1155 NFTs supporting listing, buying, and bidding.
 */
contract NFTMarketplace is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    // Represents a market item
    struct MarketItem {
        uint256 itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        uint256 price;
        bool sold;
        bool isERC1155;
    }

    // itemId => MarketItem
    mapping(uint256 => MarketItem) private idToMarketItem;

    // Events
    event MarketItemCreated(
        uint256 indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        uint256 price,
        bool isERC1155
    );
    event MarketItemSold(
        uint256 indexed itemId,
        address indexed buyer,
        uint256 price
    );

    /**
     * @notice List an ERC-721 token on the marketplace
     * @param nftContract Address of the ERC-721 contract
     * @param tokenId Token ID to list
     * @param price Sale price in wei
     */
    function createMarketItem(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) external nonReentrant {
        require(price > 0, "Price must be at least 1 wei");

        _itemIds.increment();
        uint256 itemId = _itemIds.current();

        // Transfer the NFT to the marketplace contract
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        idToMarketItem[itemId] = MarketItem(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            price,
            false,
            false
        );

        emit MarketItemCreated(itemId, nftContract, tokenId, msg.sender, price, false);
    }

    /**
     * @notice Purchase a listed item
     * @param itemId ID of the market item
     */
    function createMarketSale(uint256 itemId) external payable nonReentrant {
        MarketItem storage item = idToMarketItem[itemId];
        require(msg.value == item.price, "Please submit the asking price");
        require(!item.sold, "Item already sold");

        item.seller.transfer(msg.value);

        // Transfer NFT to buyer
        IERC721(item.nftContract).transferFrom(address(this), msg.sender, item.tokenId);

        item.sold = true;
        _itemsSold.increment();

        emit MarketItemSold(itemId, msg.sender, item.price);
    }

    /**
     * @notice Fetch unsold market items
     */
    function fetchMarketItems() external view returns (MarketItem[] memory) {
        uint256 totalItems = _itemIds.current();
        uint256 unsoldCount = totalItems - _itemsSold.current();
        MarketItem[] memory items = new MarketItem[](unsoldCount);
        uint256 currentIndex = 0;

        for (uint256 i = 1; i <= totalItems; i++) {
            if (!idToMarketItem[i].sold) {
                items[currentIndex] = idToMarketItem[i];
                currentIndex++;
            }
        }
        return items;
    }
}
