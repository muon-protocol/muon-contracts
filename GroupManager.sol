// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./CollateralManager.sol";

contract GroupManager is Ownable {

	enum StakeDuration { DAY, WEEK, MONTH, YEAR }

	struct Group {
		uint256 id;
		address [] participants;
		uint256 groupStakeBalance;
	}

	struct Stake {
		uint256 amount;
		uint256 timestamp;
		StakeDuration duration;
		bool autoRenewal;
	}

	uint256 minGroupSize;
	uint256 maxGroupSize;
	uint256 tssThreshold; 
	uint256 nextGroupId;

	// Nodes balances
	mapping(address => uint256) public balances;
	// Nodes stake balances
	mapping(address => uint256) public stakeBalances;

	// ID to group mapping
	mapping(uint256 => Group) public groups;

	// Node to group mapping
	mapping(address => Group) public groups;

	// Group list
	uint256 [] public group;

	constructor() {
		nextGroupId = 1;
		minGroupSize = 8;
		maxGroupSize = 80;
		tssThreshold = 8;
	}

	function getNodeGroup(address _node) public returns (address) {
	}

	function getGroupNodes(address _group) public returns (address []) {
	}

	function joinToGroup() public returns (uint256) {
	}

	/**
	 * @param      _id: ID of the group
	 * @param _address: Address of tss distributed key, created in group.
	 * @params   _sigs: We needs to at least "tssThreshold" numner of group nodes confirmation.
	 * ========================================================================================
	 * @return True/False: Is success done or not.
	 **/
	function setGroupAddress(uint256 _id, address _address, bytes[] calldata _sigs) public returns (bool) {
	}

	function deposit(uint256 amount) public {
	}

	function stake(uint256 amount, uint8 _period) public {
		// subrtact from balances and add to stakeBalances
	}

	function withdraw(uint256 amount) public {
		// withdraw from balances
	}

	function adminAddNodeToGroup() public onlyOwner {
	}

	function adminSetGroupSize(uint256 _min, uint256 _max) public onlyOwner {
	}

	function adminSetTssThreshold(uint256 _tssThreshold) public onlyOwner {
	}
}