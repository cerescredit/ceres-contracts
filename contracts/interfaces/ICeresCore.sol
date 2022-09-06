// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ICeresCore {
    /**
     * @dev add address relation
     * @param _child: address of the child
     * @param _parent: address of the parent
     * @return reward ceres token amount for add relation
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
     * @dev distribute token
     * you must approve bigger than 'amount' allowance of token for ceres relation contract before call
     * require (incentiveAmount + parentAmount + grandpaAmount) <= amount
     * @param token: token address to be distributed
     * @param to: to address
     * @param amount: total amount of distribute
     * @param incentiveAmount: amount of incentive reward
     * @param parentAmount: amount of parent reward
     * @param grandpaAmount: amount of grandpa reward
     */
    function distribute(
        address token,
        address to,
        uint256 amount,
        uint256 incentiveAmount,
        uint256 parentAmount,
        uint256 grandpaAmount
    ) external returns(uint256 distributedAmount);
}