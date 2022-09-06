// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import './CfoTakeable.sol';

interface IERC721TransferMin {
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}

interface IERC1155TransferMin {
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;
}

abstract contract CfoNftTakeable is CfoTakeable {

    event CfoTakedERC721(address caller, address token, address to,uint256 tokenId);
    event CfoTakedERC1155(address caller,address token,address to,uint256 tokenId,uint256 amount);
    
    function takeERC721(address to,address token,uint tokenId) external onlyCfoOrOwner {
        require(to != address(0),"to can not be address 0");
        IERC721TransferMin(token).safeTransferFrom(address(this), to, tokenId);

        emit CfoTakedERC721(msg.sender,to,token,tokenId);
    }

    function takeERC1155(address to,address token,uint tokenId,uint amount) external onlyCfoOrOwner {
        require(to != address(0),"to can not be address 0");
        require(amount > 0,"amount can not be 0");
        IERC1155TransferMin(token).safeTransferFrom(address(this), to, tokenId,amount,"");

        emit CfoTakedERC1155(msg.sender,to,token,tokenId, amount);
    }
}