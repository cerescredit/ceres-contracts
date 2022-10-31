// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import './libs/SafeMath.sol';
import './interfaces/IERC20.sol';
import './libs/SafeERC20.sol';
import './libs/ReentrancyGuard.sol';
import './interfaces/ICeresCore.sol';
import './libs/CfoTakeable.sol';
import './libs/Adminable.sol';

interface IDID {
    function didOwnerOf(string memory did) external view returns(address);
}

contract CeresBinder is CfoTakeable,Adminable,ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address public immutable ceresRelation;
    
    IDID public immutable ceresDID;
    
    address public rewardsToken;
    
    uint public selfAmount;
    
    uint public parentAmount;
    
    uint public grandpAmount;
    
    uint256 public addRelationBNBFee = 0;
    
    mapping(address => bool) public exists;
    uint256 public recordedUserCount;

    constructor(
        address _ceresRelation,
        address _ceresDID,
        address _reawrdsToken
    ){
        require(_ceresRelation != address(0),"_ceresRelation can not be address 0");
        require(_ceresDID != address(0),"_nameNft can not be address 0");

        ceresRelation = _ceresRelation;
        ceresDID = IDID(_ceresDID);
        rewardsToken = _reawrdsToken;
        
        if(_reawrdsToken != address(0)){
           IERC20(_reawrdsToken).safeApprove(_ceresRelation,type(uint256).max);
        }
    }

    // query the relationship between two addresses
    function isParent(address child,address parent) external view returns(bool){
        return ICeresCore(ceresRelation).isParent(child, parent);
    }    
    
    // query inviter of address
    function parentOf(address account) external view returns(address){
        return ICeresCore(ceresRelation).parentOf(account);
    }

    function addRelation(address child,address parent) external payable nonReentrant {
        require(child == msg.sender,"child must be tx sender");
        require(msg.value >= addRelationBNBFee,"value too low");
        ICeresCore(ceresRelation).addRelation(child, parent);

        _afterAddedRelation(child);
    }

    function addRelationByDID(string calldata did) external payable nonReentrant {
        require(msg.value >= addRelationBNBFee,"value too low");
        address parent = ceresDID.didOwnerOf(did);
        ICeresCore(ceresRelation).addRelation(msg.sender, parent);

        _afterAddedRelation(msg.sender);       
    }

    function _afterAddedRelation(address child) internal {

        address rewardToken_ = rewardsToken;
        if(rewardToken_ != address(0)){
            (uint selfAmount_,uint parentAmount_,uint grandpaAmount_) = (selfAmount,parentAmount,grandpAmount);
            uint totalAmount_ = selfAmount_.add(parentAmount_).add(grandpaAmount_);
            if(totalAmount_ > 0 && IERC20(rewardToken_).balanceOf(address(this)) >= totalAmount_){
                ICeresCore(ceresRelation).distribute(rewardToken_, child, totalAmount_, 0,parentAmount_, grandpaAmount_);
            }
        }

        if(!exists[child]){
            recordedUserCount += 1;
            exists[child] = true;
        }
    }

    function setRewardsToken(address _rewardsToken) external onlyAdmin {
        address old = rewardsToken;
        require(old != _rewardsToken,"_rewardsToken can not be same as old");
        rewardsToken = _rewardsToken;
        if(_rewardsToken != address(0)){
            IERC20(_rewardsToken).safeApprove(ceresRelation,type(uint256).max);
        }
    }

    function setRewardAmounts(uint _selfAmount,uint _parentAmount,uint _grandpaAmount) public onlyAdmin {
        selfAmount = _selfAmount;
        parentAmount = _parentAmount;
        grandpAmount = _grandpaAmount;
    }

    function setAddRelationBNBFee(uint _fee) external onlyAdmin {
        addRelationBNBFee = _fee;
    }
}
