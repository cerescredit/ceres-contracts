// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import './SafeCast.sol';

library NFTPropertyPacker {
    using SafeCast for uint256;

    function calcDataPos(uint pos) internal pure returns(uint packedDataIndex,uint posInPacked){
        packedDataIndex = pos / 32;
        posInPacked = pos % 32;
    }

    function bytesToBytes32(bytes memory b) internal pure returns(bytes32){
        require(b.length <=32,"bytesToBytes32: invalid length");        
        uint r;
        uint l = b.length <=32 ? b.length : 32;
        for(uint i=0;i<l;i++){
            r += uint(uint8(b[32 - i - 1])) << (i*8);
        }
        return bytes32(r);   
    }

    function readPartialData(bytes32 packedData,uint pos,uint length) internal pure returns(uint256){
        require(pos + length <= 32,"readPartialData: out of bounds");     
        return uint(packedData << (pos * 8) >> (32 - length) * 8);
    }

    function readUint16(bytes32 packedData,uint pos) internal pure returns(uint16) {
        return uint16(readPartialData(packedData,pos,2));
    }

    function readUint32(bytes32 packedData,uint pos) internal pure returns(uint32) {
        return uint32(readPartialData(packedData,pos,4));
    }

    function readUint64(bytes32 packedData,uint pos) internal pure returns(uint64) {
        return uint64(readPartialData(packedData,pos,8));
    }

    function readUint96(bytes32 packedData,uint pos) internal pure returns(uint96) {
        return uint96(readPartialData(packedData,pos,12));
    }

    function readUint128(bytes32 packedData,uint pos) internal pure returns(uint128) {
        return uint128(readPartialData(packedData,pos,16));
    }

    function modifyPartialData(bytes32 packedProps,uint256 pos,uint256 length,uint newVal) internal pure returns(bytes32){
        require(length > 0,"modifyPropertieFromPackedData: length can not be 0");
        require(pos + length <= 32,"modifyPropertieFromPackedData: out of bounds");
        require(length == 32 || newVal < 2 ** (length * 8),"modifyPropertieFromPackedData: new val overflow");
        uint beforeData = uint(packedProps >> (32 - pos) * 8 << (32 - pos) * 8);
        uint afterData = uint(packedProps << (pos + length) * 8 >> (pos + length) * 8);
        return bytes32(beforeData + (newVal << (32 - pos - length) * 8) + afterData);
    }    
}
