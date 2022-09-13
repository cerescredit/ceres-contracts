
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import '../libs/Math.sol';
import '../libs/SafeMath.sol';
import '../libs/Ownable.sol';

interface IERC20Min {
    function balanceOf(address account) external view returns (uint256);

    function totalSupply() external view returns (uint256);
}

interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns(uint[] memory amounts);

    function getAmountsOut(uint256 amountIn, address[] memory path) external view returns (uint256[] memory amounts);
}

interface ISwapPair {    
    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface ISwapFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

library SwapCalc {
    using SafeMath for uint256;

    function circulatingSupply(address token) internal view returns(uint){
        return IERC20Min(token).totalSupply() - IERC20Min(token).balanceOf(address(0));
    }

    function circulatingMarketCap(address token,address swapRouter, address stableToken) internal view returns(uint){
        return circulatingSupply(token).mul(tokenUSDPrice(token,swapRouter,stableToken));
    }

    function totalMarketCap(address token,address swapRouter, address stableToken) internal view returns(uint){
        return IERC20Min(token).totalSupply().mul(tokenUSDPrice(token,swapRouter,stableToken));
    }

    function tokenUSDPrice(address token, address swapRouter,address stableToken) internal view returns(uint){
        address factory = ISwapRouter(swapRouter).factory();
        if(factory == address(0)){
            return 0;
        }

        address stablePair = ISwapFactory(factory).getPair(token,stableToken);
        if(stablePair != address(0)){
            return getTokenRate(token,stableToken,stablePair);
        }
        address weth = ISwapRouter(swapRouter).WETH();
        address wethPair = ISwapFactory(factory).getPair(token,weth);
        if(wethPair == address(0)){
            return 0;
        }
        address stableWithWETHPair = ISwapFactory(factory).getPair(stableToken,weth);
        if(stableWithWETHPair == address(0)){
            return 0;
        }

        return getTokenRate(token,weth,wethPair).mul(getTokenRate(weth,stableToken,stableWithWETHPair)).div(1e18);
    }

    function getTokenRate(address baseToken,address unitToken, address pair) internal view returns(uint){
        if(baseToken == unitToken){
            return 1e18;
        }

        (uint reserve0,uint reserve1,) = ISwapPair(pair).getReserves();
        (uint unitReserve,uint baseReserve) = ISwapPair(pair).token0() == unitToken ? (reserve0,reserve1) : (reserve1,reserve0);
        return unitReserve.mul(1e18).div(baseReserve);
    }

    function tokenToLiquidity(address swapRouter, address token,address otherToken,uint tokenAmount) internal view returns(uint){
        if(tokenAmount == 0){
            return 0;
        }
        address factory = ISwapRouter(swapRouter).factory();
        if(factory == address(0)){
            return 0;
        }
        address pair = ISwapFactory(factory).getPair(token,otherToken);
        if(pair == address(0)){
            return 0;
        }
        
        return calcTokenToLiquidity(pair,token,tokenAmount);
    }   

    function calcTokenToLiquidity(address pair,address token,uint tokenAmount) internal view returns(uint){
        uint liquidity = 0;
        (uint _reserve0, uint _reserve1,) = ISwapPair(pair).getReserves();
        (uint _tokenReserve,uint _otherTokenReserve) = token == ISwapPair(pair).token0() ? (_reserve0, _reserve1) : (_reserve1, _reserve0);
        uint _equalOtherTokenAmount = _otherTokenReserve.mul(tokenAmount).div(_tokenReserve);
        uint _totalSupply = IERC20Min(pair).totalSupply();
        liquidity = Math.min(tokenAmount.mul(_totalSupply).div(2) / _tokenReserve, _equalOtherTokenAmount.mul(_totalSupply).div(2) / _otherTokenReserve) ;
        
        return liquidity;
    }
}