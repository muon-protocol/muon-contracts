// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IMuonNodeManager.sol";


// TODOs: 
// 1- auto compunding
// 2- add events
// 3- allow the DAO to edit the configs

contract MuonNodeStaking is AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant DAO_ROLE = keccak256("DAO_ROLE");

    bytes32 public constant REWARD_ROLE = keccak256("REWARD_ROLE");

    struct User{
        uint256 balance;
        uint256 paidReward;
        uint256 paidRewardPerToken;
        uint256 pendingRewards;

        uint256 withdrawable;
    }

    mapping (address => User) public users;

    IERC20 public muonToken;

    IMuonNodeManager public nodeManager;

    uint256 public totalStaked;

    // ===== configs ======

    // Nodes should deactive their nodes on
    // NodeManager first and wait for some time
    // to be able to unstake
    uint256 public exitPendingPeriod = 7 days;

    uint256 public minStakeAmountPerNode = 1000 ether;
    uint256 public maxStakeAmountPerNode = 10000 ether;

    uint256 public REWARD_PERIOD = 30 days;

    uint256 public periodFinish;
    uint256 public rewardRate;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    modifier updateReward(address _forAddress) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (_forAddress != address(0)) {
            users[_forAddress].pendingRewards = earned(_forAddress);
            users[_forAddress].paidRewardPerToken = rewardPerTokenStored;
        }
        _;
    }

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

    /**
     * @dev Existing nodes can stake more using this method.
     * The total staked amount should be less 
     * than "maxStakeAmountPerNode"
     */
    function stakeMore(uint256 amount) public{
        IMuonNodeManager.Node memory node = nodeManager.stakerAddressInfo(msg.sender);
        require(node.id != 0 && node.active, "No active node");
        require(
            amount + users[msg.sender].balance <= maxStakeAmountPerNode,
            ">maxStakeAmountPerNode"
        );
        _stake(amount);
    }

    function _stake(uint256 amount) private updateReward(msg.sender){
        muonToken.transferFrom(msg.sender, address(this), amount);
        users[msg.sender].balance += amount;
        totalStaked += amount;
    }

    function withdraw() public{
        IMuonNodeManager.Node memory node = nodeManager.stakerAddressInfo(msg.sender);
        require(
            !node.active && node.endTime < (block.timestamp + exitPendingPeriod),
            "Exit time not reached yet"
        );
        uint256 amount = users[msg.sender].withdrawable;
        require(amount > 0, "withdrawable=0");
        muonToken.transfer(msg.sender, amount);

        users[msg.sender].withdrawable = 0;
    }

    function requestExit() public updateReward(msg.sender) {
        IMuonNodeManager.Node memory node = nodeManager.stakerAddressInfo(msg.sender);
        require(node.id != 0, "Node not found");
        // TODO: force nodes to be in the network for a minimum time

        uint256 amount = earned(msg.sender) + users[msg.sender].balance;
        require(amount > 0, "amount=0");

        totalStaked -= users[msg.sender].balance;

        users[msg.sender].balance = 0;
        users[msg.sender].pendingRewards = 0;
        users[msg.sender].paidReward = 0;

        users[msg.sender].withdrawable = amount;

        nodeManager.deactiveNode(node.id);
    }

    /**
     * @dev Lets the users stake 
     * minimum "minStakeAmountPerNode" tokens
     * to run a node.
     */
    function addMuonNode(
        address nodeAddress, 
        string calldata peerId,
        uint256 intialStakeAmount
    ) public {
        require(
            intialStakeAmount >= minStakeAmountPerNode,
            "intialStakeAmount is not enough for running a node"
        );
        _stake(intialStakeAmount);
        nodeManager.addNode(
            nodeAddress,
            msg.sender, // stakerAddress,
            peerId,
            true // active
        );
    }

    function distributeRewards(uint256 reward) public 
        updateReward(address(0)) 
        onlyRole(REWARD_ROLE)
    {
        if (block.timestamp >= periodFinish) {
            rewardRate = reward / REWARD_PERIOD;
        } else {
            uint256 remaining = periodFinish - block.timestamp;
            uint256 leftover = remaining * rewardRate;
            rewardRate = (reward + leftover) / REWARD_PERIOD;
        }
        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp + REWARD_PERIOD;
    }

    function rewardPerToken() public view returns(uint256) {
        return totalStaked == 0 ? rewardPerTokenStored :
            rewardPerTokenStored + (
                (lastTimeRewardApplicable() - lastUpdateTime)*rewardRate*1e18/totalStaked
            );
    }

    function earned(address account) public view returns(uint256) {
        return users[account].balance*(
            rewardPerToken() - users[account].paidRewardPerToken
        )/1e18 + users[account].pendingRewards;
    }

    function lastTimeRewardApplicable() public view returns(uint256) {
        return block.timestamp < periodFinish ? block.timestamp : periodFinish;
    }
}
