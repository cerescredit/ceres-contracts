// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import './NFTPropertyPackerV3.sol';
import './SafeMath.sol';

abstract contract NFTPropertyStorage {

    mapping(uint256 => mapping(uint256 => bytes32)) internal _itemPackedProps;

    event PropertiesUpdated(address updater,uint tokenId,uint mapIndex,bytes32 oldPackedProps,bytes32 newPackedProps);

    function packedPropertiesOf(uint tokenId,uint mapIndex) public virtual view returns(bytes32){
        return _itemPackedProps[tokenId][mapIndex];
    }

    function readProperty(uint tokenId,uint mapIndex,uint pos,uint length) public virtual view returns(uint){
        return NFTPropertyPacker.readPartialData(_itemPackedProps[tokenId][mapIndex], pos, length);
    }

    function _updateProperty(uint tokenId,uint mapIndex,uint pos,uint len,uint newVal) internal {
        require(len == 32 || newVal < 2**(len*8),"_updateProperty: newVal overflow");
        bytes32 oldProps = _itemPackedProps[tokenId][mapIndex];
        bytes32 newProps =  NFTPropertyPacker.modifyPartialData(oldProps, pos, len, newVal);
        _itemPackedProps[tokenId][mapIndex] = newProps;

        emit PropertiesUpdated(msg.sender,tokenId,mapIndex,oldProps, newProps);
    }

    function _updatePackedProperties(uint tokenId,uint mapIndex,bytes32 newPackedProps) internal {
        bytes32 oldProps = _itemPackedProps[tokenId][mapIndex];
        _itemPackedProps[tokenId][mapIndex] = newPackedProps;

        emit PropertiesUpdated(msg.sender,tokenId,mapIndex,oldProps, newPackedProps);
    }

    function _addNewItem(uint tokenId,bytes32[] memory packedProps) internal {
        require(_itemPackedProps[tokenId][0] == bytes32(0),"_addNewItem: token id is existed");
        for(uint i=0;i<packedProps.length;i++){
            _itemPackedProps[tokenId][i] = packedProps[i];
        }
    }
}