// SPDX-License-Identifier: APACHE-2.0
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/governance/utils/IVotes.sol";
import "forge-std/Test.sol";
import "../../src/proposer/OnChainProposer.sol";
import "../mocks/ProposalReceiver.sol";
import "../mocks/Vote.sol";

uint256 constant mininalVote = 1000;

contract OnChainProposerTest is Test {
    OnChainProposer proposer;

    function setUp() public {
        proposer = new OnChainProposer(mininalVote);
    }

    function testInstantiated() public {
        assertEq(proposer.proposalCount(), 0);
        assertEq(proposer.minimalVotingPower(), mininalVote);
    }

    function testCanSetGovernor() public {
        ProposalReceiverMock governor = new ProposalReceiverMock();
        proposer.setGovernor(IProposalReceiver(address(governor)));
        assertEq(address(proposer.daoGovernor()), address(governor));
    }

    function testFailSetGovernorTwice() public {
        ProposalReceiverMock governor = new ProposalReceiverMock();
        proposer.setGovernor(IProposalReceiver(address(governor)));
        proposer.setGovernor(IProposalReceiver(address(governor)));
    }

    function testAllowGovernorSetMinimalVotingPower() public {
        ProposalReceiverMock governor = new ProposalReceiverMock();
        proposer.setGovernor(IProposalReceiver(address(governor)));
        vm.prank(address(governor));
        proposer.setMinimalVotingPower(10);
        assertEq(proposer.minimalVotingPower(), 10);
    }

    function testFailNonGovernorSetMinimalVotingPower() public {
        ProposalReceiverMock governor = new ProposalReceiverMock();
        proposer.setGovernor(IProposalReceiver(address(governor)));
        vm.prank(address(0x123));
        proposer.setMinimalVotingPower(10);
    }

    function testCanPropose() public {
        ProposalReceiverMock governor = new ProposalReceiverMock();
        proposer.setGovernor(IProposalReceiver(address(governor)));
        governor.setProposalId(42);

        VoteMock voteMock = new VoteMock();
        governor.setVotingModule(IVotes(address(voteMock)));
        voteMock.setVotes(mininalVote);

        // Prepare proposal
        address[] memory targets = new address[](1);
        targets[0] = address(0x123);
        uint256[] memory values = new uint256[](1);
        values[0] = 42;
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = abi.encodeWithSignature("setProposalCount(uint256)", 1);
        string memory description = "test";

        // Propose
        proposer.propose(targets, values, calldatas, description);

        // Check proposal
        assertEq(proposer.proposalCount(), 1);
        assertEq(proposer.proposalIDs(0), 42);
        (
            address[] memory newTargets,
            uint256[] memory newValues,
            bytes[] memory newCalldatas,
            string memory newDescription
        ) = proposer.getProposalContent(42);
        assertEq(newTargets, targets);
        assertEq(newValues, values);
        assertEq(newCalldatas[0], calldatas[0]);
        assertEq(newDescription, description);
        assertEq(proposer.getProposalCreator(42), address(this));

        // Check mock call
        assertEq(governor.getCounter(), 1);
        (
            address[] memory calledTargets,
            uint256[] memory calledValues,
            bytes[] memory calledCalldatas,
            string memory calledDescription
        ) = governor.getCalledContent();
        assertEq(calledTargets, targets);
        assertEq(calledValues, values);
        assertEq(calledCalldatas[0], calldatas[0]);
        assertEq(calledDescription, description);

        // Can propose a second time
        governor.setProposalId(43);

        // Prepare proposal
        targets[0] = address(0x456);
        values[0] = 43;
        calldatas[0] = abi.encodeWithSignature("setProposalCount(uint256)", 2);
        description = "newtest";

        // Propose
        proposer.propose(targets, values, calldatas, description);

        // Check proposal
        assertEq(proposer.proposalCount(), 2);
        assertEq(proposer.proposalIDs(1), 43);
        (newTargets, newValues, newCalldatas, newDescription) = proposer
            .getProposalContent(43);
        assertEq(newTargets, targets);
        assertEq(newValues, values);
        assertEq(newCalldatas[0], calldatas[0]);
        assertEq(newDescription, description);

        assertEq(governor.getCounter(), 2);
    }

    function testFailProposeNotEnoughVote() public {
        ProposalReceiverMock governor = new ProposalReceiverMock();
        proposer.setGovernor(IProposalReceiver(address(governor)));

        VoteMock voteMock = new VoteMock();
        governor.setVotingModule(IVotes(address(voteMock)));
        voteMock.setVotes(mininalVote - 1);

        // Prepare proposal
        address[] memory targets = new address[](1);
        targets[0] = address(0x123);
        uint256[] memory values = new uint256[](1);
        values[0] = 42;
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = abi.encodeWithSignature("setProposalCount(uint256)", 1);
        string memory description = "test";

        // Propose
        proposer.propose(targets, values, calldatas, description);
    }
}
