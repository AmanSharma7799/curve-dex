// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

// Gauge contract for staking LP tokens and distributing CRV rewards
contract Gauge {
    IERC20 public lpToken;
    IERC20 public rewardToken;

    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public rewardDebt;
    mapping(address => uint256) public pendingRewards;

    uint256 public accRewardPerShare;
    uint256 public lastRewardTime;
    uint256 public rewardRate; // tokens per second

    constructor(address _lpToken, address _rewardToken, uint256 _rewardRate) {
        lpToken = IERC20(_lpToken);
        rewardToken = IERC20(_rewardToken);
        rewardRate = _rewardRate;
        lastRewardTime = block.timestamp;
    }

    function updatePool() public {
        uint256 lpSupply = lpToken.balanceOf(address(this));
        if (block.timestamp > lastRewardTime && lpSupply > 0) {
            uint256 timeElapsed = block.timestamp - lastRewardTime;
            uint256 reward = timeElapsed * rewardRate;
            accRewardPerShare += (reward * 1e12) / lpSupply;
            lastRewardTime = block.timestamp;
        }
    }

    function deposit(uint256 amount) external {
        updatePool();
        if (balanceOf[msg.sender] > 0) {
            uint256 pending = (balanceOf[msg.sender] * accRewardPerShare) /
                1e12 -
                rewardDebt[msg.sender];
            pendingRewards[msg.sender] += pending;
        }
        lpToken.transferFrom(msg.sender, address(this), amount);
        balanceOf[msg.sender] += amount;
        rewardDebt[msg.sender] =
            (balanceOf[msg.sender] * accRewardPerShare) /
            1e12;
    }

    function withdraw(uint256 amount) external {
        updatePool();
        uint256 pending = (balanceOf[msg.sender] * accRewardPerShare) /
            1e12 -
            rewardDebt[msg.sender];
        pendingRewards[msg.sender] += pending;

        balanceOf[msg.sender] -= amount;
        lpToken.transfer(msg.sender, amount);
        rewardDebt[msg.sender] =
            (balanceOf[msg.sender] * accRewardPerShare) /
            1e12;
    }

    function claim() external {
        updatePool();
        uint256 pending = (balanceOf[msg.sender] * accRewardPerShare) /
            1e12 -
            rewardDebt[msg.sender];
        pending += pendingRewards[msg.sender];
        pendingRewards[msg.sender] = 0;
        rewardDebt[msg.sender] =
            (balanceOf[msg.sender] * accRewardPerShare) /
            1e12;
        rewardToken.transfer(msg.sender, pending);
    }
}
