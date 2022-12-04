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
        uint256 paidReward;
        uint256 paidRewardPerToken;
        uint256 pendingRewards;
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

    uint256 public PERIOD = 30 days;

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

    function stake(uint256 amount) public updateReward(msg.sender){
        muonToken.transferFrom(msg.sender, address(this), amount);
        users[msg.sender].balance += amount;
        totalStaked += amount;
    }

    // function unstake(uint256 amount) public updateReward(msg.sender){
    //     IMuonNodeManager.Node memory node = nodeManager.stakerAddressInfo(msg.sender);
    //     require(
    //         node.id == 0 || // not added a node yet
    //         // node is deactived `unstakePendingPeriod` secs ago on the NodeManager
    //         (!node.active && node.endTime < (block.timestamp + unstakePendingPeriod) )
    //     );
    //     totalStaked -= amount;
    //     users[msg.sender].balance -= amount;

    //     muonToken.transfer(msg.sender, amount);
    // }

    function exit() public updateReward(msg.sender) {
        IMuonNodeManager.Node memory node = nodeManager.stakerAddressInfo(msg.sender);
        require(
            node.id == 0 || // not added a node yet
            // node is deactived `unstakePendingPeriod` secs ago on the NodeManager
            (!node.active && node.endTime < (block.timestamp + unstakePendingPeriod) )
        );

        uint256 amount = earned(msg.sender) + users[msg.sender].balance;
        require(amount > 0, 'amount=0');

        totalStaked -= users[msg.sender].balance;

        users[msg.sender].balance = 0;
        users[msg.sender].pendingRewards = 0;

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

    function notifyReward(uint256 reward) public updateReward(address(0)){
        if (block.timestamp >= periodFinish) {
            rewardRate = reward / PERIOD;
        } else {
            uint256 remaining = periodFinish - block.timestamp;
            uint256 leftover = remaining * rewardRate;
            rewardRate = (reward + leftover) / PERIOD;
        }
        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp + PERIOD;
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
