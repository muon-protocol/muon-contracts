// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IMuonNodeManager.sol";

contract MuonNodeStaking is AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant DAO_ROLE = keccak256("DAO_ROLE");

    struct User{
        uint256 balance;
        // uint256 paidReward;
        // uint256 paidRewardPerToken;
    }

    mapping (address => User) public users;

    IERC20 public muonToken;

    IMuonNodeManager public nodeManager;

    uint256 public totalStaked;

    // ===== configs ======

    // Nodes should deactive their nodes on
    // NodeManager first and wait for some time
    // to be able to unstake
    uint256 public unstakePendingPeriod = 7 days;

    // min stake amount for the nodes
    uint256 public nodeMinStakeAmount = 1000 ether;

    constructor(
        address muonTokenAddress,
        address nodeManagerAddress
    ){
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(ADMIN_ROLE, msg.sender);
        _setupRole(DAO_ROLE, msg.sender);

        muonToken = IERC20(muonTokenAddress);
        nodeManager = IMuonNodeManager(nodeManagerAddress);
    }

    function stake(uint256 amount) public{
        muonToken.transferFrom(msg.sender, address(this), amount);
        users[msg.sender].balance += amount;
        totalStaked += amount;
    }

    function unstake(uint256 amount) public{
        IMuonNodeManager.Node memory node = nodeManager.stakerAddressInfo(msg.sender);
        require(
            node.id == 0 || // not added a node yet
            // node is deactived `unstakePendingPeriod` secs ago on the NodeManager
            (!node.active && node.endTime < (block.timestamp + unstakePendingPeriod) )
        );
        totalStaked -= amount;
        users[msg.sender].balance -= amount;

        muonToken.transfer(msg.sender, amount);
    }

    /**
     * @dev A staker who have staked enough token
     * can add a node to the NodeManager.
     * NodeManager contract should grant ADMIN_ROLE access
     * to the NodeStaking contract.
     */
    function addMuonNode(
        address nodeAddress, 
        string calldata peerId
    ) public{
        require(
            users[msg.sender].balance >= nodeMinStakeAmount,
            "staked amount is not enough for running a node"
        );
        nodeManager.addNode(
            nodeAddress,
            msg.sender, // stakerAddress,
            peerId,
            true // active
        );
    }
}
