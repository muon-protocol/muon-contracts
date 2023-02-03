// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./MuonNodeManager.sol";

contract MuonNodesReport is AccessControl {

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    MuonNodeManager public nodeManager;

    constructor(address nodeManagerAddress){
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(ADMIN_ROLE, msg.sender);

        nodeManager = MuonNodeManager(nodeManagerAddress);
    }

    function setNodeManager(address nodeManagerAddress) public onlyRole(ADMIN_ROLE) {
        nodeManager = MuonNodeManager(nodeManagerAddress);
    }

    /**
     * @dev Returns list of nodes between ID:from and ID:to.
     */
    function getAllNodes(uint256 from, uint256 to) public view returns(
        IMuonNodeManager.Node[] memory allNodes
    ){
        uint256 count = to - from + 1;
        allNodes = new MuonNodeManager.Node[](count);
        for(uint256 i = 0; i < count; i++){
            (
                uint64 id,
                address nodeAddress,
                address stakerAddress,
                string memory peerId,
                bool active,
                uint256 startTime,
                uint256 lastEditTime,
                uint256 endTime,
                bool isDeployer
            ) = nodeManager.nodes(i+from);

            allNodes[i] = IMuonNodeManager.Node(
                id,
                nodeAddress,
                stakerAddress,
                peerId,
                active,
                startTime,
                lastEditTime,
                endTime,
                isDeployer
            );
        }
    }
}
