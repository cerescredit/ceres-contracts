
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library BytesHelper {

    function bytes32ToUint256(bytes32 buffer) internal pure returns(uint256){
        return uint(buffer);
    }

    function bytes32ToAddress(bytes32 buffer) internal pure returns(address){
        uint ui = uint(buffer);
        require(ui <= type(uint160).max,"bytes32 overflow uint160");

        return address(uint160(ui));
    }

    function bytes32ToUint8(bytes32 buffer) internal pure returns(uint8){
        uint ui = uint(buffer);
        require(ui <= type(uint8).max,"bytes32 overflow uint8");

        return uint8(ui);
    }

    function addressToBytes32(address addr) internal pure returns(bytes32){
        return bytes32(uint256(uint160(addr)));
    }
}