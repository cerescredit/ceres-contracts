
// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import './libs/Pausable.sol';
import './libs/ReentrancyGuard.sol';
import './libs/Adminable.sol';
import './libs/CfoNftTakeable.sol';

interface IDIDNFT {
    function allPropsLength() external view returns(uint256);
    function safeMint(address to,uint[] memory numberProps,string[] memory stringProps, string memory did,string memory imageUrl) external returns(uint256);
    function didExists(string memory did) external view returns(bool);
    function mintedTokenOf(address account) external view returns(uint);
}

contract DIDMinter is CfoNftTakeable,Adminable,Pausable,ReentrancyGuard {

    IDIDNFT public immutable ceresDIDNFT;
    uint public mintBNBFee;
    event Minted(address caller,uint tokenId);
    
    constructor(
        address _ceresDIDNFT
    ) {
        require(_ceresDIDNFT != address(0),"_ceresDIDNFT vault can not be 0");
        ceresDIDNFT = IDIDNFT(_ceresDIDNFT);
    }

    function mint(string memory did,string memory imageUrl) external payable whenNotPaused nonReentrant {
        require(msg.value >= mintBNBFee,"insufficient input value");
        require(bytes(did).length > 0,"did can not be empty");
        require(bytes(imageUrl).length > 0,"image can not be empty");
        require(!ceresDIDNFT.didExists(did),"did existed");

        uint[] memory numberProps = new uint[](ceresDIDNFT.allPropsLength());
        string[] memory stringProps = new string[](ceresDIDNFT.allPropsLength());
        uint tokenId = ceresDIDNFT.safeMint(msg.sender, numberProps,stringProps, did, imageUrl);

        emit Minted(msg.sender, tokenId);
    }

    function infos(address account) external view returns(uint _mintBNBFee,uint _mintedTokenId){
        _mintBNBFee = mintBNBFee;
        _mintedTokenId = ceresDIDNFT.mintedTokenOf(account);
    }

    function setMintFee(uint fee) external onlyAdmin {
        mintBNBFee = fee;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}
