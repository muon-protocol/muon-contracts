// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MuonTestToken is ERC20, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    bool public allowPublicMint = true;

    constructor() ERC20("Alice", "ALICE"){
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(ADMIN_ROLE, msg.sender);
    }

    function mint(address account, uint256 amount) public {
        require(
            allowPublicMint || hasRole(ADMIN_ROLE, msg.sender),
            "Access Denied"
        );
        _mint(account, amount);
    }

    function setPublicMint(bool val) public onlyRole(ADMIN_ROLE){
        allowPublicMint = val;
    }
}
