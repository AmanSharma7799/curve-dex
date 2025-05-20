// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// ERC20 LP Token
import "../../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract LPToken is ERC20 {
    address public pool;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        pool = msg.sender;
    }

    function mint(address to, uint256 amount) external {
        require(msg.sender == pool, "Not pool");
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        require(msg.sender == pool, "Not pool");
        _burn(from, amount);
    }
}
