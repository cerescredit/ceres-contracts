

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import './Ownable.sol';

abstract contract NFTMintManager is Ownable {

    mapping(address => bool) public isMinter;
    
    mapping(address => bool) public isUpdater;
    
    uint256 public nextTokenId = 1;

    modifier onlyMinter {
        require(isMinter[msg.sender],"onlyMinter: caller must be minter");
        _;
    }

    modifier onlyUpdater {
        require(isUpdater[msg.sender],"onlyUpdater: caller must be updater");
        _;
    }

    function addMinter(address minter) public onlyOwner {
        require(minter != address(0),"invalid new minter");
        isMinter[minter] = true;
    }
    
    function removeMinter(address minter) public onlyOwner {
        require(minter != address(0),"invalid new minter");
        isMinter[minter] = false;
    }

    function addUpdater(address updater) public onlyOwner {
        require(updater!=address(0),"updater can not be address 0");
        isUpdater[updater] = true;
    }

    function removeUpdater(address updater) public onlyOwner {
        require(updater != address(0),"updater can not be address 0");
        isUpdater[updater] = false;
    }
}
