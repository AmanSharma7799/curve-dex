// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

// veCRV - Voting Escrow CRV Token
contract veCRV {
    IERC20 public crv;

    struct Lock {
        uint256 amount;
        uint256 unlockTime;
    }

    mapping(address => Lock) public locks;

    constructor(address _crv) {
        crv = IERC20(_crv);
    }

    function lock(uint256 amount, uint256 time) external {
        require(time > block.timestamp, "Invalid time");
        crv.transferFrom(msg.sender, address(this), amount);
        locks[msg.sender] = Lock(amount, time);
    }

    function getVotes(address user) public view returns (uint256) {
        Lock memory lockData = locks[user];
        if (block.timestamp >= lockData.unlockTime) return 0;
        return lockData.amount * (lockData.unlockTime - block.timestamp);
    }
}
