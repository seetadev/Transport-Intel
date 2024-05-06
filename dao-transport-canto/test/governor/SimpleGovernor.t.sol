// SPDX-License-Identifier: APACHE-2.0
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/governance/utils/IVotes.sol";
import "@openzeppelin/contracts/governance/IGovernor.sol";
import "@openzeppelin/contracts/governance/Governor.sol";
import "forge-std/Test.sol";
import "../mocks/Vote.sol";
import "../../src/governor/SimpleGovernor.sol";

contract SimpleGovernorTest is Test {
    SimpleGovernor dao;
    VoteMock voteMock;

    function setUp() public {
        voteMock = new VoteMock();

        dao = new SimpleGovernor(
            "daoTest",
            "daoDescription",
            "daoImage",
            IVotes(address(voteMock)),
            address(0x123),
            50,
            10,
            10
        );
    }

    function testInstantiated() public {
        assertEq(dao.name(), "daoTest");
        assertEq(dao.description(), "daoDescription");
        assertEq(dao.imageURL(), "daoImage");
        assertEq(dao.proposer(), address(0x123));
        assertEq(address(dao.votingModule()), address(voteMock));
        assertEq(dao.votingDelay(), 10);
        assertEq(dao.votingPeriod(), 10);
        assertEq(dao.quorumNumerator(), 50);
        assertEq(dao.proposalThreshold(), 0);
    }

    function testAllowUpdateVotingDelay() public {
        vm.prank(address(dao));
        dao.updateVotingDelay(20);
        assertEq(dao.votingDelay(), 20);
    }

    function testFailUpdateVotingDelayNonSelf() public {
        dao.updateVotingDelay(20);
    }

    function testAllowUpdateVotingPeriod() public {
        vm.prank(address(dao));
        dao.updateVotingPeriod(20);
        assertEq(dao.votingPeriod(), 20);
    }

    function testFailUpdateVotingPeriodNonSelf() public {
        dao.updateVotingPeriod(20);
    }

    function testAllowUpdateQuorumFraction() public {
        vm.prank(address(dao));
        dao.updateQuorumFraction(20);
        assertEq(dao.quorumNumerator(), 20);
    }

    function testFailUpdateQuorumFractionNonSelf() public {
        dao.updateQuorumFraction(20);
    }

    function testAllowUpdateVotingModule() public {
        vm.prank(address(dao));
        dao.updateVotingModule(IVotes(address(0x456)));
        assertEq(address(dao.votingModule()), address(0x456));
    }

    function testFailUpdateVotingModuleNonSelf() public {
        dao.updateVotingModule(IVotes(address(0x456)));
    }

    function testAllowUpdateProposer() public {
        vm.prank(address(dao));
        dao.updateProposer(address(0x456));
        assertEq(dao.proposer(), address(0x456));
    }

    function testFailUpdateProposerNonSelf() public {
        dao.updateProposer(address(0x456));
    }

    function testAllowUpdateImageURL() public {
        vm.prank(address(dao));
        dao.updateImageURL("newImage");
        assertEq(dao.imageURL(), "newImage");
    }

    function testFailUpdateImageURLNonSelf() public {
        dao.updateImageURL("newImage");
    }

    function testAllowUpdateDescription() public {
        vm.prank(address(dao));
        dao.updateDescription("newDescription");
        assertEq(dao.description(), "newDescription");
    }

    function testFailUpdateDescriptionNonSelf() public {
        dao.updateDescription("newDescription");
    }

    function testAllowProposerPropose() public {
        voteMock.setPastTotalSupply(1000);

        // Prepare proposal
        address[] memory targets = new address[](1);
        targets[0] = address(0x123);
        uint256[] memory values = new uint256[](1);
        values[0] = 42;
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = abi.encodeWithSignature("setProposalCount(uint256)", 1);
        string memory description = "test";

        vm.prank(address(0x123));
        uint256 proposalId = dao.propose(
            targets,
            values,
            calldatas,
            description
        );
        assertEq(
            uint(dao.state(proposalId)),
            uint(IGovernor.ProposalState.Pending)
        );
        assertEq(dao.quorumVotes(proposalId), 500);
    }

    function testFailNonProposerPropose() public {
        // Prepare proposal
        address[] memory targets = new address[](1);
        targets[0] = address(0x123);
        uint256[] memory values = new uint256[](1);
        values[0] = 42;
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = abi.encodeWithSignature("setProposalCount(uint256)", 1);
        string memory description = "test";

        vm.prank(address(0x456));
        dao.propose(targets, values, calldatas, description);
    }
}
