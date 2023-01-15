// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IMuonNodeManager.sol";


// TODOs: 
// 1- auto compunding
// 2- add events
// 3- allow the DAO to edit the configs

/**
 * @dev Staking contracts for the Muon Nodes
 *
 * Important functions:
 * 
 * - addMuonNode
 * Lets the users stake more than a predefined minimum 
 * amount of tokens and add a node.
 *
 * - stakeMore
 * Existing nodes can stake more. The rewards will be distributed
 * based on the staked amounts
 *
 * - requestExit
 * Nodes that want to exit the network, need to call this function
 * to remove their nodes from the network. The staked amount will be
 * kept in the contract for a period and then they can withdraw 
 *
 * - withdraw
 * Lets the users withdraw their staked amount + total rewards
 */
contract MuonNodeStakingUpgradeable is Initializable, AccessControlUpgradeable {
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
    uint256 public exitPendingPeriod;

    uint256 public minStakeAmountPerNode;
    uint256 public maxStakeAmountPerNode;

    uint256 public REWARD_PERIOD;

    uint256 public periodFinish;
    uint256 public rewardRate;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    /**
     * @dev Modifier that updates the reward parameters
     * before all of the functions that can change the rewards.
     *
     * `_forAddress` should be address(0) when new rewards are distributing.
     */
    modifier updateReward(address _forAddress) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (_forAddress != address(0)) {
            users[_forAddress].pendingRewards = earned(_forAddress);
            users[_forAddress].paidRewardPerToken = rewardPerTokenStored;
        }
        _;
    }

    /**
     * @dev Sets the muonToken and nodeManager
     */
    
    // constructor(
    //     address muonTokenAddress,
    //     address nodeManagerAddress
    // ){
    //     _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    //     _setupRole(ADMIN_ROLE, msg.sender);
    //     _setupRole(DAO_ROLE, msg.sender);

    //     muonToken = IERC20(muonTokenAddress);
    //     nodeManager = IMuonNodeManager(nodeManagerAddress);
    // }

    function __MuonNodeStakingUpgradeable_init(
        address muonTokenAddress,
        address nodeManagerAddress
    ) internal initializer {
        __AccessControl_init();


        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(ADMIN_ROLE, msg.sender);
        _setupRole(DAO_ROLE, msg.sender);

        muonToken = IERC20(muonTokenAddress);
        nodeManager = IMuonNodeManager(nodeManagerAddress);

        exitPendingPeriod = 7 days;
        minStakeAmountPerNode = 1000 ether;
        maxStakeAmountPerNode = 10000 ether;
        REWARD_PERIOD = 30 days;

    }

    function initialize(
        address muonTokenAddress,
        address nodeManagerAddress
    ) external initializer {
        __MuonNodeStakingUpgradeable_init(muonTokenAddress, nodeManagerAddress);
    }

    function __MuonNodeStakingUpgradeable_init_unchained() internal initializer {}


    /**
     * @dev Existing nodes can stake more using this method.
     * The total staked amount should be less 
     * than `maxStakeAmountPerNode`
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

    /**
     * @dev Allows the users to withdraw
     *
     * Users should {requestExit} first. Their nodes will
     * be deatived and after `exitPendingPeriod` secs, they can
     * withdraw
     */
    function withdraw() public{
        IMuonNodeManager.Node memory node = nodeManager.stakerAddressInfo(msg.sender);
        require(
            !node.active && (node.endTime + exitPendingPeriod) < block.timestamp,
            "Exit time not reached yet"
        );
        uint256 amount = users[msg.sender].withdrawable;
        require(amount > 0, "withdrawable=0");
        muonToken.transfer(msg.sender, amount);

        users[msg.sender].withdrawable = 0;
    }

    /**
     * @dev Allows the users to request to exit their nodes 
     * from the nework
     */
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
     * minimum `minStakeAmountPerNode` tokens
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
        require(
            intialStakeAmount <= maxStakeAmountPerNode,
            ">maxStakeAmountPerNode"
        );
        _stake(intialStakeAmount);
        nodeManager.addNode(
            nodeAddress,
            msg.sender, // stakerAddress,
            peerId,
            true // active
        );
    }

    /**
     * @dev A wallet/contract that has REWARD_ROLE access 
     * can call this function to distribute the rewards.
     *
     * Tokens should be transferred to the contract before 
     * calling this function.
     */
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

    /**
     * @dev Calculates rewardPerToken until now
     */
    function rewardPerToken() public view returns(uint256) {
        return totalStaked == 0 ? rewardPerTokenStored :
            rewardPerTokenStored + (
                (lastTimeRewardApplicable() - lastUpdateTime)*rewardRate*1e18/totalStaked
            );
    }

    /**
     * @dev Total rewards for an `account`
     */
    function earned(address account) public view returns(uint256) {
        return users[account].balance*(
            rewardPerToken() - users[account].paidRewardPerToken
        )/1e18 + users[account].pendingRewards;
    }

    /**
     * @dev Last time of the current reward period
     */
    function lastTimeRewardApplicable() public view returns(uint256) {
        return block.timestamp < periodFinish ? block.timestamp : periodFinish;
    }

    // ======== DAO functions ====================

    function setExitPendingPeriod(uint256 val) public onlyRole(DAO_ROLE){
        exitPendingPeriod = val;    
    }
    
    function setMinStakeAmountPerNode(uint256 val) public onlyRole(DAO_ROLE){
        minStakeAmountPerNode = val;    
    }

    function setMaxStakeAmountPerNode(uint256 val) public onlyRole(DAO_ROLE){
        maxStakeAmountPerNode = val;    
    }
}
