// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
 
contract EnhancedStorage {
    address public owner;
    uint256 private storedData;
    
    event ValueChanged(address indexed who, uint256 oldValue, uint256 newValue);
    
    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can call this func!!!");
        _;
    }
    
    function set(uint256 x) public onlyOwner {
        uint256 oldValue = storedData;
        storedData = x;
        emit ValueChanged(msg.sender, oldValue, x);
    }
    
    function get() public view returns (uint256) {
        return storedData;
    }
}