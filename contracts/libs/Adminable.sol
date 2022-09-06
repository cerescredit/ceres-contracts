// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import './Ownable.sol';

abstract contract Adminable is Ownable {

    mapping(address => bool) public isAdmin;

    modifier onlyAdmin {
        require(isAdmin[msg.sender],"onlyAdmin: forbidden");
        _;
    }

    constructor () {
        isAdmin[msg.sender] = true;
    }

    function addAdmin(address _admin) external onlyOwner {
        require(_admin != address(0),"admin can not be address 0");
        isAdmin[_admin] = true;
    }

    function removeAdmin(address _admin) external onlyOwner {
        require(_admin != address(0),"admin can not be address 0");
        isAdmin[_admin] = false;
    }
}