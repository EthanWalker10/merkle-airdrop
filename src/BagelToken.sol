// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract BagelToken is ERC20, Ownable {
    // the deployer is the owner of the contract
    constructor() ERC20("Bagel Token", "BT") Ownable(msg.sender) { }

    // Only onwer can mint for others
    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }
}
