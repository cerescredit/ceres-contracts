// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import './libs/Address.sol';
import './libs/Pausable.sol';
import './libs/SafeMath.sol';
import './libs/IERC20Metadata.sol';
import './libs/CfoTakeable.sol';
import './libs/BlackListable.sol';

contract CeresToken is CfoTakeable,Pausable,BlackListable,IERC20Metadata {
    using Address for address;
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    
    mapping(address => mapping(address => uint256)) private _allowances;

    //mainnet: 
    string private constant _name = "Ceres Token";
    
    //mainnet: 
    string private constant _symbol = "Ceres";
    
    uint256 private _totalSupply = 60000000 * 1e18;

    /// @notice The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    /// @notice The EIP-712 typehash for the permit struct used by the contract
    bytes32 public constant PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    bytes32 public immutable DOMAIN_SEPARATOR;

    /// @notice A record of states for signing / validating signatures
    mapping (address => uint) public nonces;

    mapping(address => bool) private _whiteList;

    uint256 public feeRate = 1 * 1e16;
    
    address public feeTo = address(0x01887CB054499ff7c66c7845198Ef7395A300375);

    constructor(){

        DOMAIN_SEPARATOR = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(_name)), _getChainId(), address(this)));

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);

        _whiteList[address(0x01887CB054499ff7c66c7845198Ef7395A300375)] = true;
        _whiteList[msg.sender] = true;
    }

    function name() public pure override returns (string memory) {
        return _name;
    }

    function symbol() public pure override returns (string memory) {
        return _symbol;
    }

    function decimals() public pure override returns (uint8) {
        return 18;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function permit(address owner, address spender, uint amount, uint deadline, uint8 v, bytes32 r, bytes32 s) external {
        require(block.timestamp <= deadline, "ERC20permit: expired");
        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, amount, nonces[owner]++, deadline));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "ERC20permit: invalid signature");
        require(signatory == owner, "ERC20permit: unauthorized");

        _approve(owner, spender, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(!isBlackListed[sender] && !isBlackListed[recipient],"_beforeTokenTransfer: forbidden");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }

        uint recipientAmount = amount;
        if(!isWhiteList(sender) && !isWhiteList(recipient)){
            address feeTo_ = feeTo;
            if(feeTo_ != address(0)){
                uint feeAmount = amount.mul(feeRate).div(1e18);
                if(feeAmount > 0){
                    recipientAmount = amount.sub(feeAmount);
                    _balances[feeTo_] = _balances[feeTo_].add(feeAmount);
                    emit Transfer(sender, feeTo_, feeAmount); 
                }
            }
        }

        _balances[recipient] += recipientAmount;

        emit Transfer(sender, recipient, recipientAmount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function burn(uint256 amount) public {
        require(amount > 0,"ERC20: amount can not be 0");
        _burn(msg.sender, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal whenNotPaused {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {}
    
    function _getChainId() internal view returns (uint) {
        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }

    function mint(uint256 amount) public onlyOwner {
        _mint(_msgSender(), amount);
    }

    function burn(address account, uint256 amount) public onlyOwner {
        _burn(account, amount);
    }

    function isWhiteList(address account) public view returns(bool){
        return _whiteList[account];
    }
    
    function addWhiteList(address account) external onlyOwner {
        require(account != address(0),"account can not be address 0");
        _whiteList[account] = true;
    }

    function removeWhiteList(address account) external onlyOwner {
        require(account != address(0),"account can not be address 0");
        _whiteList[account] = false;
    }

    function setFeeTo(address account) external onlyOwner {
        require(account != address(0),"account can not be address 0");
        feeTo = account;
        _whiteList[account] = true;
    }

    function setFeeRate(uint _feeRate) external onlyOwner {
        feeRate = _feeRate;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
       _unpause();
    }
}
