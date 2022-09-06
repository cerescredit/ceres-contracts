//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './Ownable.sol';

abstract contract BlackListable is Ownable {

    function getBlackListStatus(address _maker) external view returns (bool) {
        return isBlackListed[_maker];
    }

    mapping (address => bool) public isBlackListed;
    
    function _addBlackList (address _evilUser) internal {
        isBlackListed[_evilUser] = true;
        emit AddedBlackList(_evilUser);
    }

    function _removeBlackList (address _clearedUser) internal {
        isBlackListed[_clearedUser] = false;
        emit RemovedBlackList(_clearedUser);
    }

    modifier notBlackListed {
        require(!isBlackListed[_msgSender()],"blacklisted");
        _;
    }

    event AddedBlackList(address _user);

    event RemovedBlackList(address _user);

}