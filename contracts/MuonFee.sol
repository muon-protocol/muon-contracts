// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract MuonFee is AccessControl{
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    
    bytes32 public constant DAO_ROLE = keccak256("DAO_ROLE");

    // TODO: handle non-EVM chains
    // what if someone wants to pay the fees on BSC
    // and use on Solana
    mapping(address => uint256) public balances;

    event Deposit(address indexed addr, uint256 amount, address payer);

    constructor(){
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(ADMIN_ROLE, msg.sender);
        _setupRole(DAO_ROLE, msg.sender);
    }

    function deposit(uint256 amount) public {
        depositFor(msg.sender, amount);
    }

    function depositFor(address forAddress, uint256 amount) public{
        balances[forAddress] += amount;
        emit Deposit(forAddress, amount, msg.sender);
    }

    function withdraw(uint256 amount) public{
        // TODO: get sigs from Muon and let the user withdraw 
        // the remaining balance
    }
}
