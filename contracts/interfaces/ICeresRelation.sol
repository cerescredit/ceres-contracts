// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ICeresRelation {
    /**
     * @dev query seconds of a month
     * @return seconds of a month
     */
    function monthScale() external pure returns(uint256);

    /**
     * @dev query stake base amount,stake monthes formula: (1 + usingMonthes) * usingMonthes / 2 * stakeBase
     * @return stake base amount
     */
    function stakeBase() external pure returns(uint256);

    /**
     * @dev query stake for month limit
     * @return stake for month limit
     */
    function maxStakeMonth() external view returns(uint256);

    /**
     * @dev query staked limit
     * @return stake limit
     */
    function maxStakeAmount() external view returns(uint256);

    /**
     * @dev query global trial seconds
     * @return seconds of global trial
     */
    function globalTrial() external view returns(uint256);

    /**
     * @dev query stake enable status
     * @return stake enable status
     */
    function stakeEnabled() external view returns(bool);

    /**
     * @dev query withdraw enable status
     * @return withdraw enable status
     */
    function withdrawEnabled() external view returns(bool);

    /**
     * @dev query burn expired stake enable status
     * @return burn expired stake enable status
     */
    function burnEnabled() external view returns(bool);

    /**
     * @dev query stakingToken address
     * @return burn stakingToken address
     */
    function stakingToken() external view returns(address);    

    /**
     * @dev add address relation
     * @param _child: address of the child
     * @param _parent: address of the parent
     * @return reward token amount for add relation
     */
    function addRelation(address _child, address _parent) external returns(uint256);

    /**
     * @dev query child and parent is associated
     * @param child: address of the child
     * @param parent: address of the parent
     * @return child and parent is associated
     */
    function isParent(address child,address parent) external view returns(bool);

    /**
     * @dev query parent of address
     * @param account: address of the child
     * @return parent address
     */
    function parentOf(address account) external view returns(address);

    /**
     * @dev stake stakingToken to ceres relation
     * @param forAccount: address of stake for
     * @param amount: stake amount
     * @return whether or not the stake succeeded
     */
    function stake(address forAccount,uint256 amount) external returns(bool);

    /**
     * @dev query address staked amount
     * @param account: address of to be queried
     * @return staked amount
     */
    function stakeOf(address account) external view returns(uint256);

    /**
     * @dev withdraw stake
     * require withdraw is enabled
     * @param to: withdraw to address
     */
    function withdraw(address to) external;

    /**
     * @dev burn expired stake of account
     * require burn expired stake is enabled
     * @param account: address of expired stake
     */
    function burnExpiredStake(address account) external;

    /**
    * @dev distribute token
    * you must approve bigger than 'amount' allowance of token for ceres relation contract before call
    * require (incentiveAmount + parentAmount + grandpaAmount) <= amount
    * @param token: token address to be distributed
    * @param to: to address
    * @param amount: total amount of distribute
    * @param incentiveAmount: amount of incentive reward
    * @param parentAmount: amount of parent reward
    * @param grandpaAmount: amount of grandpa reward
    * @return distributedAmount : distributed token amount
    */
    function distribute(
        address token,
        address to,
        uint256 amount,
        uint256 incentiveAmount,
        uint256 parentAmount,
        uint256 grandpaAmount
    ) external returns(uint256 distributedAmount);

    /**
     * @dev query trial expire at 
     * require burn expired stake is enabled
     * @param account: the address of to be queried
     * @return trial expire at of queried address
     */
    function trialExpireAt(address account) external view returns(uint256);

    /**
     * @dev query expire at
     * require burn expired stake is enabled
     * @param account: the address of to be queried
     * @return expire at of queried address
     */
    function expireAt(address account) external view returns(uint256);

    /**
     * @dev query call function 'distribute' fee (default is 0)
     * @return call function 'distribute' fee
     */
    function distributeFee() external view returns(uint256);

    /**
     * @dev query call add relation rewards amount 
     * @return add relation rewards amount 
     */
    function bindReward() external view returns(uint256);

    /**
     * @dev query remaining rewards amount
     * @return remaining rewards amount
     */
    function remainingRewards() external view returns(uint256);

    /**
     * @dev query total minted rewards amount
     * @return total minted rewards amount
     */
    function mintedRewards() external view returns(uint256);
    
    //an event thats emitted when new relation added
    event AddedRelation(address child,address parent);

    //an event thats emitted when staked
    event Staked(address forAccount,uint256 amount);

    //an event thats emitted when token distributed
    event Distributed(address sender,address token, address to,uint256 toAmount,address parent, uint256 parantAmount,address grandpa, uint256 grandpaAmount);
}