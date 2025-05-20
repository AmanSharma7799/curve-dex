// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Core StableSwap Math Library
library StableSwapMath {
    function getY(
        uint256 A,
        uint256 x,
        uint256 D
    ) internal pure returns (uint256 y) {
        uint256 c = (D * D) / (x * 2);
        c = (c * D * 1e18) / (A * 4 * x);
        uint256 b = D / A + x;
        y = D;

        for (uint i = 0; i < 256; i++) {
            uint256 yPrev = y;
            y = (y * y + c) / (2 * y + b - D);
            if ((y > yPrev ? y - yPrev : yPrev - y) < 1) break;
        }
    }

    function getD(
        uint256[] memory xp,
        uint256 A
    ) internal pure returns (uint256 D) {
        uint256 nCoins = xp.length;
        uint256 S = 0;
        for (uint i = 0; i < nCoins; i++) S += xp[i];

        if (S == 0) return 0;
        D = S;
        for (uint i = 0; i < 255; i++) {
            uint256 D_P = D;
            for (uint j = 0; j < nCoins; j++) {
                D_P = (D_P * D) / (xp[j] * nCoins);
            }
            uint256 prevD = D;
            D =
                ((A * S * nCoins + D_P * nCoins) * D) /
                ((A - 1) * D + (nCoins + 1) * D_P);
            if ((D > prevD ? D - prevD : prevD - D) < 1) break;
        }
    }
}
