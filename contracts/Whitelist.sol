// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Whitelist is Ownable {
    mapping(address => bool) whitelist;
    uint public whitelistTotal = 0;
    uint256 public maxWhitelistAddr = 1000;

    event AddedToWhitelist(address indexed account);
    event RemovedFromWhitelist(address indexed account);

    modifier onlyWhitelisted() {
        require(isWhitelisted(msg.sender));
        _;
    }

    function getTotalWhitelist() external view returns (uint256){
        return whitelistTotal;
    }

    function add(address[] memory _address) public onlyOwner{
        require(whitelistTotal + _address.length <= maxWhitelistAddr, "Max limit");
        
        for(uint8 i = 0; i < _address.length; i++){
             whitelistTotal++;
             whitelist[_address[i]] = true;
             emit AddedToWhitelist(_address[i]);
        }
    }

    function remove(address _address) public onlyOwner{
        whitelist[_address] = false;
        whitelistTotal--;
        emit RemovedFromWhitelist(_address);
    }

    function isWhitelisted(address _address) public view returns(bool) {
        return whitelist[_address];
    }
}