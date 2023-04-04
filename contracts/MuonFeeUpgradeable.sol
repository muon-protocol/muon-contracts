// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IMuonNodeManager.sol";


// TODOs: 
// 1- handle non-EVM chains
// Users should be able to deposit fees into any chain(e.g BSC)
// and use on any chains(e.g Solana)

// 2- payFor support
// Users should be able to deposit using one wallet and then
// connect more wallets and pay the fees for all wallets from
// a single fee balance

/**
 * @dev MuonFee contract
 * Users can lock $MUON token to be paid az request fees
 * on Muon Network.
 */
contract MuonFeeUpgradeable is Initializable, AccessControlUpgradeable {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant DAO_ROLE = keccak256("DAO_ROLE");

    struct User{
        uint256 balance;
    }
    mapping (address => User) public users;

    IERC20 public muonToken;

    event Deposit(
        address indexed addr,
        uint256 amount,
        uint256 balance,
        address payer
    );

    function __MuonFeeUpgradeable_init(
        address muonTokenAddress
    ) internal initializer {
        __AccessControl_init();

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(ADMIN_ROLE, msg.sender);
        _setupRole(DAO_ROLE, msg.sender);

        muonToken = IERC20(muonTokenAddress);
    }

    function initialize(
        address muonTokenAddress
    ) external initializer {
        __MuonFeeUpgradeable_init(muonTokenAddress);
    }

    function __MuonFeeUpgradeable_init_unchained() internal initializer {}

    function deposit(uint256 amount) public{
        depositFor(msg.sender, amount);
    }

    function depositFor(address forAddress, uint256 amount) public{
        muonToken.transferFrom(msg.sender, address(this), amount);
        users[forAddress].balance += amount;
        emit Deposit(forAddress, amount, users[forAddress].balance, msg.sender);
    }

    function withdraw(uint256 amount) public{
        // TODO: get sigs from Muon and let the user withdraw 
        // the unused fees
    }

    function adminWithdraw(uint256 amount, address _to, address _tokenAddr) public onlyRole(ADMIN_ROLE){
        require(_to != address(0));
        if(_tokenAddr == address(0)){
          payable(_to).transfer(amount);
        }else{
          IERC20(_tokenAddr).transfer(_to, amount);  
        }
    }
}
