// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import './Ownable.sol';
import './SafeERC20.sol';

abstract contract CfoTakeable is Ownable {
    using Address for address;
    using SafeERC20 for IERC20;

    event CfoTakedToken(address caller, address token, address to,uint256 amount);
    event CfoTakedETH(address caller,address to,uint256 amount);

    address public cfo;

    modifier onlyCfoOrOwner {
        require(msg.sender == cfo || msg.sender == owner(),"onlyCfo: forbidden");
        _;
    }

    constructor(){
        cfo = msg.sender;
    }

    function takeToken(address token,address to,uint256 amount) public onlyCfoOrOwner {
        require(token != address(0),"invalid token");
        require(amount > 0,"amount can not be 0");
        require(to != address(0) && !to.isContract(),"invalid to address");
        IERC20(token).safeTransfer(to, amount);

        emit CfoTakedToken(msg.sender,token,to, amount);
    }

    function takeETH(address to,uint256 amount) public onlyCfoOrOwner {
        require(amount > 0,"amount can not be 0");
        require(address(this).balance>=amount,"insufficient balance");
        require(to != address(0) && !to.isContract(),"invalid to address");
        
        payable(to).transfer(amount);

        emit CfoTakedETH(msg.sender,to,amount);
    }

    function takeAllToken(address token, address to) public {
        uint balance = IERC20(token).balanceOf(address(this));
        if(balance > 0){
            takeToken(token, to, balance);
        }
    }

    function takeAllTokenToSelf(address token) external {
        takeAllToken(token,msg.sender);
    }

    function takeAllETH(address to) public {
        uint balance = address(this).balance;
        if(balance > 0){
            takeETH(to, balance);
        }
    }

    function takeAllETHToSelf() external {
        takeAllETH(msg.sender);
    }

    function setCfo(address _cfo) external onlyOwner {
        require(_cfo != address(0),"_cfo can not be address 0");
        cfo = _cfo;
    }
}