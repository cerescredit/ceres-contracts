# Ceres development document
## instructions
    import 'ICeresRelation.sol'
## functions
### **monthScale**
- Returns how many seconds a month equals
#### Parameters
- none
#### Returns
- `uint256` - Seconds of a month
<h1></h1>

### **stakeBase**
- Query the calculation base of the quantity to be pledged -

- formula for calculating the quantity to be pledged
          

        //When the number of used months is equal to 1, the quantity to be pledged is equal to the calculation base
        //When the number of used months is greater than 1, the quantity to be pledged is calculated by the following formula
        (1+used months) * used months/2 * calculation base
#### Parameters
- none
#### Returns
- `uint256` - Calculation base of quantity to be pledged
<h1></h1>

### **maxStakeMonth**
- Query the maximum number of months that can be pledged. If the number reaches this number, it will be regarded as long-term availability
#### Parameters
- none
#### Returns
- `uint256` - Maximum number of pledge months
<h1></h1>

### **maxStakeAmount**
- Query the maximum quantity that can be pledged. When the pledge reaches this quantity, it is considered as long-term availability
#### Parameters
- none
#### Returns
- `uint256` - Maximum quantity that can be pledged
<h1></h1>

### **globalTrial**
- Query global trial time ，unit：second
#### Parameters
- none
#### Returns
- `uint256` - Global trial time
<h1></h1>

### **stakeEnabled**
- Query the opening status of pledge
#### Parameters
- none
#### Returns
- `bool` - Pledge open status
<h1></h1>

### **withdrawEnabled**
- Query whether to allow redemption of pledge
#### Parameters
- none
#### Returns
- `bool` - Is it allowed to redeem the pledge
<h1></h1>

### **burnEnabled**
- Query whether the expired pledge is allowed to be destroyed
#### Parameters
- none
#### Returns
- `bool` - Is it allowed to destroy the expired pledge
<h1></h1>

### **stakingToken**
- Query pledged token address
#### Parameters
- none
#### Returns
- `address` - Pledged token address
<h1></h1>

### **addRelation**
- Add reference relationship
- Require `_child` must be tx sender
- RRequire that '_child' cannot be equal to '_parent' or the parent of '_parent'
#### Parameters
- `_child|address` - Child address
- `_parent|address` - Parent address
#### Returns
- `uint256` - reward token amount
<h1></h1>

### **isParent**
- Query child and parent is associated
#### Parameters
- `child|address` - Child address
- `parent|address` - Parent Address
#### Returns
- `bool` - Whether or not associated
<h1></h1>

### **parentOf**
- Query the parent of the specified address
#### Parameters
- `account|address` - Address to query
#### Returns
- `address` - Parent address
<h1></h1>

### **stake**
- stake
#### Parameters
- `forAccount|address` - Staking for which contract address
- `amount|address` - Staking number
#### Returns
- `bool` - Whether to stake successfully or not
<h1></h1>

### **stakeOf**
- Query the staked quantity at the specified address
#### Parameters
- `account|address` - The Address to query
#### Returns
- `uint256` - Staked number
<h1></h1>

### **withdraw**
- Redemption staking tokens (available only when the CeresRelation contract is opened to allow redemption)
#### Parameters
- `to|address` - Redeemed address
#### Returns
- none
<h1></h1>

### **burnExpiredStake**
- Destroy expired pledge (only available when the CeresRelation contract is opened to allow the destruction of expired pledge)
#### Parameters
- `account|address` -Address of expired staking tokens to be destroyed
#### Returns
- none
<h1></h1>

### **distribute**
- Distribute tokens
- Require `incentiveAmount` + `parentAmount` + `grandpaAmount` Less than `amount`
#### Parameters
- `token|address` - The address of token to be distributed
- `to|address` - The main receiving address of this distribution
- `amount|uint256` - Distribution quantity
- `incentiveAmount|uint256` - amount of incentive reward, `to' can get this award, which can be passed to 0
- `parentAmount|uint256` - amount of parent reward, which can be passed to 0
- `grandpaAmount|uint256` - amount of grandpa reward, which can be passed as 0
#### Returns
- `distributedAmount|uint256` - Total number of token' typed out in this distribution
<h1></h1>

### **trialExpireAt**
- Query the probation period end time of the specified address
#### Parameters
- `account|address` - address to query
#### Returns
- `uint256` - Trial period deadline
<h1></h1>

### **expireAt**
- Query the expiration time of calling the distribution interface at the specified address
#### Parameters
- `account|address` - The address to query
#### Returns
- `uint256` - Expiration time of calling distribution interface
<h1></h1>

### **distributeFee**
- Query the single charge quantity of calling distribution interface (currently 0)
#### Parameters
- none
#### Returns
- `uint256` - Number of single charges for calling distribution interface
<h1></h1>

### **bindReward**
- Query the number of rewards you can get when adding an invitation relationship
#### Parameters
- none
#### Returns
- `uint256` - Number of awards available
<h1></h1>

### **remainingRewards**
- Query the remaining quantity of prize pool for adding invitation relationship
#### Parameters
- none
#### Returns
- `uint256` - Remaining quantity of prize pool
<h1></h1>

### **mintedRewards**
- Query the total number of rewards dug up by adding invitation relationship
#### Parameters
- none
#### Returns
- `uint256` - Total rewards dug up cumulatively
<h1></h1>

## Contract addresses
### Ethereum mainnet
| Contract name | Contract address |
| -------------- | ---------------- |
| Ceres Relation | 0x5B40d90ec38b814C57077a712e3AE0259f6F5B98 |

### Ethereum Goerli testnet
| Contract name | Contract address |
| -------------- | ---------------- |
| Ceres Relation | 0x62dD0a69F7537b7a570fCb74D64571fdC6b2eF1f |

### BSC mainnet
| Contract name | Contract address |
| -------------- | ---------------- |
| Ceres Relation | 0x2fbb59aE194c9552d3bC4Aa168E9Ab684f579Fe6 |

### BSC testnet
| Contract name | Contract address |
| -------------- | ---------------- |
| Ceres Relation | 0x988258ead056CbF2d600F60F75dEa54441944f94 |

### Polygon mainnet
| Contract name | Contract address |
| -------------- | ---------------- |
| Ceres Relation | 0x5B40d90ec38b814C57077a712e3AE0259f6F5B98 |

### Polygon Mumbai testnet
| Contract name | Contract address |
| -------------- | ---------------- |
| Ceres Relation | 0x38A0e44f0D8e2986a6448Dc7e342C05018b621cD |

### Optimism
| Contract name | Contract address |
| -------------- | ---------------- |
| Ceres Relation | 0x5B40d90ec38b814C57077a712e3AE0259f6F5B98 |

### Optimism Goerli testnet
| Contract name | Contract address |
| -------------- | ---------------- |
| Ceres Relation | 0xf41B35c3e9C3108D2572e97C1f4d0124C8a4C81f |

### zkSync testnet
| Contract name | Contract address |
| -------------- | ---------------- |
| Ceres Relation | 0x62B231b9dd1dAD0c4F4162d591cb4D78f097aEdb |

### HECO mainnet
| Contract name | Contract address |
| -------------- | ---------------- |
| Ceres Relation | 0x9D382B29B3e8736493dE318424667F2Cf0B4252F |

### HECO testnet
| Contract name | Contract address |
| -------------- | ---------------- |
| Ceres Relation | 0x5CE6f9143Fb6E07a0c9fDCCE255b32Ad1f8FB617 |

### HSC mainnet
| Contract name | Contract address |
| -------------- | ---------------- |
| Ceres Relation | 0xd859DadF8f36b18195419215561498D6641Ae6a9 |


## Ref：ICeresRelaton.sol
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
        event Distributed(address sender,address token, address to,uint256 toAmount,uint256 parantAmount, uint256 grandpaAmount);
    }