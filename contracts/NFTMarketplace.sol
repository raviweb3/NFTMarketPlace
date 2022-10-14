//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract NFTMarketplace is ERC721URIStorage{
    using Counters for Counters.Counter;

    struct ListedToken {
        uint256 tokenId;
        address payable owner;
        address payable seller;
        uint256 price;
        bool    isOnSale;
    }

    mapping (uint256 => ListedToken) private s_idToListedToken;

    Counters.Counter private s_tokenIds;
    Counters.Counter private s_itemsSold;

    uint256 private s_listPrice = 0.01 ether;

    address payable private s_owner;

    constructor() ERC721("NFTMarketPlace","NFTM"){
        s_owner = payable(msg.sender);
    }

    // 
    function createToken(string memory tokenURI, uint256 price) public payable returns(uint256){
        require(msg.value == s_listPrice,"Send the fee for minting");
        require( price > 0," List with price greater than 0");

        s_tokenIds.increment();
        uint256 currentTokenId = s_tokenIds.current();
        _safeMint(msg.sender, currentTokenId);

        _setTokenURI(currentTokenId, tokenURI);

        createListedToken(currentTokenId, price);

        return currentTokenId;
    }

    function createListedToken(uint256 tokenId, uint256 price) public payable{
         s_idToListedToken[tokenId] = ListedToken(
            tokenId,
            payable(address(this)),
            payable(msg.sender),
            price,
            true
        );    

        // Transfer the ownership to smart contract to execute the sale.
        _transfer(msg.sender, address(this), tokenId);
    }

    function getAllNFTs() public view returns(ListedToken[] memory){
        uint nftCount = s_tokenIds.current();
        ListedToken[] memory tokens = new ListedToken[](nftCount);

        uint currentIndex = 0;
        for(uint i=0; i < nftCount; i++){
            uint currentId = i + 1;
            ListedToken storage currentItem = s_idToListedToken[currentId];
            tokens[currentIndex] = currentItem;
            currentIndex += 1;
        }   

        return tokens;
    }

    function getMyNFTs() public view returns (ListedToken[] memory){
        uint nftCount = s_tokenIds.current();
        ListedToken [] memory tokens = new ListedToken[](nftCount);

        uint currentIndex =0;

        for(uint i=0; i < nftCount; i++){
            uint currentId = i + 1;
            ListedToken storage currentItem = s_idToListedToken[currentId];
            if(currentItem.owner == msg.sender || currentItem.seller == msg.sender){
               tokens[currentIndex] = currentItem;
               currentIndex += 1;
            }
            
        }   
         
        return tokens;
    }

    function executeSale(uint256 tokenId) public payable {
         ListedToken storage currentItem = s_idToListedToken[tokenId];
         require(msg.value == currentItem.price,"Not Enough ether send to buy this NFT");   
         s_idToListedToken[tokenId].isOnSale = true;
         s_idToListedToken[tokenId].seller = payable(msg.sender);
         s_itemsSold.increment();

         // Tranfer from Smart contract to Sender   
         _transfer(address(this), msg.sender, tokenId);

         // Provision for the next sale   
         approve(address(this), tokenId);

         // Pay the platform
         payable(s_owner).transfer(s_listPrice);
         // Pay to the seller
         payable(currentItem.seller).transfer(msg.value);
    }

    function updateListPrice(uint256 _listPrice) public {
        require(msg.sender ==  s_owner,"You must be owner to call this");
        s_listPrice = _listPrice;
    }

    function getListPrice() public view returns(uint256){
        return s_listPrice;
    }

    function getLatestListedToken() public view returns(ListedToken memory){
        uint256 currentTokenId = s_tokenIds.current();
        return s_idToListedToken[currentTokenId];
    }

    function getListedForTokenId(uint256 tokenId) public view returns(ListedToken memory){
        return s_idToListedToken[tokenId];
    }

    function getCurrentTokenId() public view returns(uint256){
        return s_tokenIds.current();
    }
}