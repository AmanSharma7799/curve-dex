// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../math/StableSwapMath.sol";
import "../tokens/LPToken.sol";

// StableSwap Pool
contract StablePool {
    using StableSwapMath for uint256[];

    address public token0;
    address public token1;
    LPToken public lpToken;

    uint256 public A = 100;
    uint256 public totalSupply;

    constructor(address _token0, address _token1) {
        token0 = _token0;
        token1 = _token1;
        lpToken = new LPToken("Curve LP", "crvLP");
    }

    function addLiquidity(uint256 amount0, uint256 amount1) external {
        require(amount0 > 0 && amount1 > 0, "Invalid amounts");
        IERC20(token0).transferFrom(msg.sender, address(this), amount0);
        IERC20(token1).transferFrom(msg.sender, address(this), amount1);
        uint256 lpAmount = (amount0 + amount1) / 2;
        lpToken.mint(msg.sender, lpAmount);
    }

    function getD() public view returns (uint256 D) {
        uint256[] memory xp = new uint256[](2);
        xp[0] = IERC20(token0).balanceOf(address(this));
        xp[1] = IERC20(token1).balanceOf(address(this));
        D = xp.getD(A);
    }

    function swap(address from, address to, uint256 dx) external {
        require(from == token0 || from == token1, "Invalid token");
        require(to == token0 || to == token1, "Invalid token");
        require(from != to, "Same token");

        IERC20(from).transferFrom(msg.sender, address(this), dx);
        uint256 x = IERC20(from).balanceOf(address(this));
        uint256 D = getD();
        uint256 y = StableSwapMath.getY(A, x, D);
        uint256 dy = IERC20(to).balanceOf(address(this)) - y;
        IERC20(to).transfer(msg.sender, dy);
    }
}
