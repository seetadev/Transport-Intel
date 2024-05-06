// SPDX-License-Identifier: APACHE-2.0
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/governance/utils/IVotes.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../governor/SimpleGovernor.sol";

interface IProposalReceiver {
    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    ) external returns (uint256);

    function votingModule() external view returns (IVotes);
}

interface IDAOProposer {
    // TODO: use interface for governor
    function setGovernor(SimpleGovernor _governor) external;
}

/**
 * @title OnChainProposer
 * @dev The on-chain proposer is a simple permissionless proposer contract for DAOGovernor that stores proposal on-chain
 * for guaranteed data availability
 */
contract OnChainProposer {
    struct ProposalContent {
        address[] targets;
        uint256[] values;
        bytes[] calldatas;
        string description;
    }

    // Address of the DAO governor
    IProposalReceiver public daoGovernor;

    // Proposal condition
    uint256 public minimalVotingPower = 0;

    // Proposal data
    uint256 public proposalCount = 0;
    mapping(uint256 => uint256) public proposalIDs;
    mapping(uint256 => ProposalContent) public proposalContents;
    mapping(uint256 => address) public proposalCreator;

    constructor(uint256 _mininalVotingPower) {
        minimalVotingPower = _mininalVotingPower;
    }

    modifier onlyGovernor() {
        require(
            msg.sender == address(daoGovernor),
            "Must be called by DAO governor"
        );
        _;
    }

    modifier requireMinimalVote() {
        require(address(daoGovernor) != address(0), "DAO governor not set");
        require(
            daoGovernor.votingModule().getVotes(msg.sender) >=
                minimalVotingPower,
            "Minimal vote requirement not met"
        );
        _;
    }

    // set the DAO governor address and transfer ownership to it
    function setGovernor(IProposalReceiver _governor) external {
        // check the address is not initialized
        require(
            address(daoGovernor) == address(0),
            "DAOProposer: DAO governor address is already initialized"
        );

        daoGovernor = _governor;
    }

    function setMinimalVotingPower(
        uint256 _mininalVotingPower
    ) public onlyGovernor {
        minimalVotingPower = _mininalVotingPower;
    }

    function getProposalCreator(uint256 id) public view returns (address) {
        return proposalCreator[id];
    }

    function getProposalContent(
        uint256 id
    )
        public
        view
        returns (
            address[] memory,
            uint256[] memory,
            bytes[] memory,
            string memory
        )
    {
        return (
            proposalContents[id].targets,
            proposalContents[id].values,
            proposalContents[id].calldatas,
            proposalContents[id].description
        );
    }

    // propose add more onchain logic and storage for UX purposes
    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    ) public requireMinimalVote returns (uint256) {
        uint256 proposalID = daoGovernor.propose(
            targets,
            values,
            calldatas,
            description
        );

        // Store the new proposal content
        proposalIDs[proposalCount] = proposalID;
        proposalContents[proposalID] = ProposalContent(
            targets,
            values,
            calldatas,
            description
        );
        proposalCount++;

        proposalCreator[proposalID] = msg.sender;

        return proposalID;
    }
}
