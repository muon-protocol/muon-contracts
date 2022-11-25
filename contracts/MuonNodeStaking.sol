// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IMuonNodeManager {
    struct Node {
        uint64 id; // incremental ID
        address nodeAddress; // will be used on the node
        address stakerAddress;
        string peerId; // p2p peer ID
        bool active;
        uint256 startTime;
        uint256 endTime;
        uint256 lastEditTime;

        // Deployer nodes on the network run
        // the deployment app and deploy the MuonApps
        bool isDeployer;
    }

    function addNode(
        address _nodeAddress,
        address _stakerAddress,
        string calldata _peerId,
        bool _active
    ) external;

    function stakerAddressInfo(address _addr) external view returns(
        Node memory node
    );
}

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

    IMuonNodeManager nodeManager;

    uint256 public totalStaked;

    // ===== configs ======

    // Nodes should deactive their nodes on
    // NodeManager first and wait for some time
    // to be able to unstake
    uint256 public unstakePendingPeriod = 7 days;

    // min stake amount for the nodes
    uint256 public nodeMinStakeAmount = 1000 ether;

    constructor(){
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(ADMIN_ROLE, msg.sender);
        _setupRole(DAO_ROLE, msg.sender);
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
