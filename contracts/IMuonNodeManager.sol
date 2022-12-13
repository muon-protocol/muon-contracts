// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

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
        // the deployment app and deploy MuonApps
        bool isDeployer;
    }

    function addNode(
        address _nodeAddress,
        address _stakerAddress,
        string calldata _peerId,
        bool _active
    ) external;

    function deactiveNode(uint64 nodeId) external;

    function stakerAddressInfo(address _addr) external view returns(
        Node memory node
    );
}
