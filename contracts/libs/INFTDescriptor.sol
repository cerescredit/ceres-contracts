// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface INFTDescriptor {
    function tokenURI(address token, uint tokenId) external view returns(string memory);
}