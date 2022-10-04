// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract MuonNodeManager is AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    struct Node {
        uint256 id; // incremental ID
        address nodeAddress; // will be used on the node
        address stakerAddress;
        string peerId; // p2p peer ID
        bool active;
        uint256 startTime;
        uint256 endTime;
    }

    // nodeId => Node
    mapping(uint256 => Node) public nodes;

    // nodeAddress => nodeId
    mapping(address => uint256) public nodeAddressIds;

    // stakerAddress => nodeId
    mapping(address => uint256) public stakerAddressIds;  

    uint256 public lastNodeId = 0;

    event AddNode(Node node);
    event RemoveNode(Node node);
    event DeactiveNode(Node node);

    constructor(){
            _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
            _setupRole(ADMIN_ROLE, msg.sender);
    }

    /**
     * @dev Adds a new node.
     *
     * Requirements:
     * - `_nodeAdrress` should be unique.
     * - `_stakerAddress` should be unique
     */
    function addNode(
        address _nodeAddress,
        address _stakerAddress,
        string calldata _peerId,
        bool _active
    ) public onlyRole(ADMIN_ROLE) {
        require(
            nodeAddressIds[_nodeAddress] == 0,
            "Duplicate nodeAddress"
        );
        require(
            nodeAddressIds[_nodeAddress] == 0,
            "Duplicate stakerAddress"
        );
        lastNodeId ++;
        nodes[lastNodeId] = Node({
            id: lastNodeId,
            nodeAddress: _nodeAddress,
            stakerAddress: _stakerAddress,
            peerId: _peerId,
            active: _active,
            startTime: block.timestamp,
            endTime: 0
        });
        
        nodeAddressIds[_nodeAddress] = lastNodeId;
        stakerAddressIds[_stakerAddress] = lastNodeId;
        emit AddNode(nodes[lastNodeId]);
    }

    /**
     * @dev Removes a node
     */
    function removeNode(
        uint256 nodeId
    ) public onlyRole(ADMIN_ROLE) {
        require(nodes[nodeId].id == nodeId, "Not found");
        nodes[nodeId].endTime = block.timestamp;
        nodes[nodeId].active = false;

        emit RemoveNode(nodes[lastNodeId]);
    }

    /**
     * @dev Allows the node's owner to deactive its node
     */
    function deactiveNode(
        uint256 nodeId
    ) public{
        require(
            msg.sender == nodes[nodeId].stakerAddress ||
            msg.sender == nodes[nodeId].nodeAddress
        );
        nodes[nodeId].endTime = block.timestamp;
        nodes[nodeId].active = false;

        emit DeactiveNode(nodes[nodeId]);
    }

    /**
     * @dev Returns list of all nodes.
     */
    function getAllNodes() public view returns(
            Node[] memory allNodes
    ){
        allNodes = new Node[](lastNodeId);
        for(uint256 i = 1; i < lastNodeId; i++){
            allNodes[i-1] = nodes[i];
        }
    }

    /**
     * @dev Returns `Node` for a valid
     * nodeAddress and an empty Node(node.id==0)
     * for an invalid nodeAddress.
     */
    function nodeAddressInfo(address _addr) public view returns(
        Node memory node
    ){
        node = nodes[nodeAddressIds[_addr]];
    }

    /**
     * @dev Returns `Node` for a valid
     * stakerAddress and an empty Node(node.id==0)
     * for an invalid stakerAddress.
     */
    function stakerAddressInfo(address _addr) public view returns(
        Node memory node
    ){
        node = nodes[stakerAddressIds[_addr]];
    }
}
