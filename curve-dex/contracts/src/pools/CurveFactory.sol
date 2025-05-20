// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./StablePool.sol";

// Factory - Deploy new Stable Pools
contract CurveFactory {
    event PoolCreated(address indexed pool);

    function deployPool(
        address token0,
        address token1
    ) external returns (address) {
        StablePool pool = new StablePool(token0, token1);
        emit PoolCreated(address(pool));
        return address(pool);
    }
}
