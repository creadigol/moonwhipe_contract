// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

import "./ERC721Enumerable.sol";
import "./Whitelist.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MoonlightTest is ERC721URIStorage, Whitelist{
    using Strings for uint256;
    uint256 public maxToken = 10900; //done
    uint256 public ownerMaxToken = 202;  //done
    uint256 public pendingRevival = 1;

    using Counters for Counters.Counter;
    Counters.Counter private tokenCounter;
    
    uint256 public otherTotalMintToken = 0;

    //contract owner 
    address public ownerAddr;
    uint256 public ownerTotalMintToken = 0;


    //minting price
    //other
    uint256 public selectedPrice = 0.08 ether;  //done
    uint256 public mintLimit = 20; //done
    
    //whitelist
    uint256 public whitelistselectedPrice = 0.06 ether; //done
    uint256 public whitelistmintLimit = 4; //done
    
    
    //base Token Url
    string public baseTokenURI;

    //start or stop event
    bool private otherSale = false;
    bool private whitelistSale = false;

    event OtherSaleEvent(bool othersale);
    event WhitelistSaleEvent(bool whitelistsale);

    modifier saleIsOpen {
        // uint256 currentTokenCounter = tokenCounter.current();
        require(otherTotalMintToken <= maxToken, "Soldout!");
        require(otherSale || whitelistSale, "Sale is not open");
        _;
    }

    constructor() public ERC721("MoonlightTest", "MOON"){
        ownerAddr = payable(msg.sender);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function setBaseURI(string memory _baseURL) public onlyOwner {
        baseTokenURI = _baseURL;
    }

    function getMaxToken() external view returns (uint256){
        return maxToken;
    }

    function getBaseURL() external view returns (string memory){
        return baseTokenURI;
    }

    function getSaleStatus() external view returns (bool){
        return otherSale;
    }

    function getWhitelistSaleStatus() external view returns (bool){
        return whitelistSale;
    }
    
    // limit for all users
    function setMaxToken(uint256 _token) public onlyOwner(){
        maxToken = _token;
    }

    // owner mint Tokens limit
    function setOwnerMaxToken(uint256 _token1) public onlyOwner(){
        ownerMaxToken = _token1;
    }

    // other users
    function setMintPrice(uint256 _price) public onlyOwner(){
        selectedPrice = _price;
    }

    function setwhitelistMintPrice(uint256 _mintPrice) public onlyOwner(){
        whitelistselectedPrice = _mintPrice;
    }

    // other Users limit
    function setMintLimit(uint256 _mintLimit) public onlyOwner(){
        mintLimit = _mintLimit;
    } 

    function setOwnerMintLimit(uint256 _ownerMint) public onlyOwner(){
        whitelistmintLimit = _ownerMint;
    }

    function getMintPrice() external view returns (uint256){
        return selectedPrice;
    }

    function getWhitelistPrice() external view returns (uint256){
        return whitelistselectedPrice;
    }

    function getPendingRivival() external view returns (uint256){
        return pendingRevival;
    }

    function totalMintedCounter() external view returns (uint256){
        return tokenCounter.current();
    }

    function totalMintToken() public view returns (uint256) {
        return otherTotalMintToken;
    }
    
    function getBalance(address _address) public view returns(uint256){
        uint256 addressBalance = ERC721.balanceOf(_address);
        return addressBalance;
    }

    function setSaleAction(bool _pause) public onlyOwner{
        otherSale = _pause;
        emit OtherSaleEvent(otherSale);
    }

    function setWhitelistSaleAction(bool _pause) public onlyOwner{
        whitelistSale = _pause;
        emit WhitelistSaleEvent(otherSale);
    }

    // only for all people
    function mintToSelected(uint256 _mintAmount, string[] memory nftData) public payable saleIsOpen {
        require(maxToken > otherTotalMintToken, 'Maximum number item has been minted');
        require(otherTotalMintToken + _mintAmount <= maxToken, "Max limit");
        
        uint256 addressBalance = ERC721.balanceOf(msg.sender);
        address wallet = _msgSender();
        bool isMinting = false;

        if(isWhitelisted(msg.sender) && whitelistSale){
            require(addressBalance + _mintAmount <= whitelistmintLimit, 'Limited NFT for whitelist users');
            require(msg.value >= whitelistselectedPrice, 'Value below selected nft minting price');
            require(whitelistSale,"sale is not open for whitelist");
            isMinting = true;
        }

        if(!isWhitelisted(msg.sender) && otherSale){
            require(addressBalance + _mintAmount <= mintLimit, 'Limited NFT for non-whitelist users');
            require(msg.value >= selectedPrice, 'Value below selected nft minting price');
            require(otherSale,"sale is not open");
            isMinting = true;
        }

        require(isMinting,"sale is not open");
        
        for(uint8 i = 0; i < _mintAmount; i++){
            otherTotalMintToken++;
            _mintAnElement(wallet, nftData[i]);
        }
        
    }

    // only for owner
    function mintToken(uint256 _mintAmount, string[] memory _nftData, address _wallet) public onlyOwner {
        require(ownerMaxToken > ownerTotalMintToken, 'Maximum number item has been minted');
        require(ownerTotalMintToken + _mintAmount <= ownerMaxToken, "Max limit");
        
        for(uint8 i = 0; i < _mintAmount; i++){
             ownerTotalMintToken++;
            _mintAnElement(_wallet, _nftData[i]);
        }
    }

    function _mintAnElement(address _to, string memory _tokenURL) private  returns (uint256){
        tokenCounter.increment();
        uint256 newTokenCounter = tokenCounter.current();

        // string memory currentBaseURI = ; //_baseURI();
        // string memory baseTokenURL = string(abi.encodePacked(currentBaseURI, newTokenCounter.toString()));

        _mint(_to, newTokenCounter);
        _setTokenURI(newTokenCounter, _tokenURL);
        return newTokenCounter;
    }

    function updateToSelected(string[] memory nftData) public onlyOwner{
        
        uint256 newTokenCounter = tokenCounter.current();
        uint256 mintcounters = 0;
        
        for(uint256 i = pendingRevival; i <= newTokenCounter ; i++){
            _setTokenURI(i, nftData[mintcounters]);
            mintcounters++;
        }
        pendingRevival = (newTokenCounter+1);
    }

    function withdraw(address payable recipient) public onlyOwner {
        uint256 balance = address(this).balance;
        recipient.transfer(balance);
    }

}