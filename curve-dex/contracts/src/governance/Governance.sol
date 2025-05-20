// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./veCRV.sol";

// Governance - Simple Proposal and Voting system
contract Governance {
    veCRV public ve;

    struct Proposal {
        string description;
        uint256 voteYes;
        uint256 voteNo;
        uint256 endTime;
        bool executed;
    }

    Proposal[] public proposals;
    mapping(uint256 => mapping(address => bool)) public voted;

    constructor(address _ve) {
        ve = veCRV(_ve);
    }

    function createProposal(string memory desc, uint256 duration) external {
        proposals.push(Proposal(desc, 0, 0, block.timestamp + duration, false));
    }

    function vote(uint256 proposalId, bool support) external {
        require(
            block.timestamp < proposals[proposalId].endTime,
            "Voting ended"
        );
        require(!voted[proposalId][msg.sender], "Already voted");
        uint256 votes = ve.getVotes(msg.sender);
        require(votes > 0, "No voting power");

        if (support) proposals[proposalId].voteYes += votes;
        else proposals[proposalId].voteNo += votes;
        voted[proposalId][msg.sender] = true;
    }

    function execute(uint256 proposalId) external {
        Proposal storage p = proposals[proposalId];
        require(block.timestamp > p.endTime, "Too early");
        require(!p.executed, "Already executed");
        require(p.voteYes > p.voteNo, "Proposal failed");
        p.executed = true;
        // Action would be executed here
    }
}
