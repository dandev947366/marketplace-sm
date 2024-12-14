// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

// INTERNAL IMPORT FOR NFT OPENZEPPELINE
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "hardhat/console.sol";

contract NFTMarketplace is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _itemsSold;
    uint256 public listingPrice = 0.0025 ether;
    address payable owner;
    mapping(uint256 => MarketItem) private idMarketItem;
    struct MarketItem {
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }
    event idMarketItemCreated(
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can change listing price");
        _;
    }

    constructor() ERC721("NFT Metaverse Token", "MYNFT") {
        owner = payable(msg.sender);
    }

    function updateListingPrice(
        uint256 _listingPrice
    ) public payable onlyOwner {
        listingPrice = _listingPrice;
    }

    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    // CREATE NFT TOKEN
    function createToken(
        string memory _tokenURI,
        uint256 _price
    ) public returns (uint256) {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, _tokenURI);
        createMarketItem(newTokenId, _price);
        return newTokenId;
    }
    // CREATE MARKET ITMES
    function createMarketItem(uint256 _tokenId, uint256 _price) private {
        require(_price > 0, "Price must be greater than 0");
        require(msg.value == listingPrice, "Price must be equal to listing price");
        idMarketItem[_tokenId] = MarketItem(
            _tokenId,
            payable(msg.sender),
            payable(address(this)),
            _price,
            false
        );
        _transfer(msg.sender, address(this), _tokenId);
        emit idMarketItemCreated(
            _tokenId,
            payable(msg.sender),
            payable(address(this)),
            _price,
            false
        );
    }
    // RESALE TOKEN
    function reSellToken(uint256 _tokenId, uint256 _price) public payable {
        require(idMarketItem[_tokenId].owner == msg.sender, "Must be owner of NFT");
        require(msg.value == listingPrice, "Price must be equal to listing price");
        idMarketItem[_tokenId].seller = payable(msg.sender);
        idMarketItem[_tokenId].owner = payable(address(this));
        idMarketItem[_tokenId].price = _price;
        idMarketItem[_tokenId].sold = true;
        _itemsSold.decrement();
        _transfer(msg.sender, address(this), _tokenId);
    }

    // CREATE MARKET ITEM SELL

}
