// SPDX-License-Identifier: APACHE-2.0
pragma solidity ^0.8.17;

// Contains integration tests for the DAO contracts

import "forge-std/Test.sol";

import "@openzeppelin/contracts/governance/IGovernor.sol";

import "../src/factory/DAOFactory.sol";
import "../src/proposer/OnChainProposer.sol";
import "../src/votes/DAOToken.sol";
import "../src/governor/SimpleGovernor.sol";

import "../src/factory/SimpleGovernorFactory.sol";
import "../src/factory/DAOTokenFactory.sol";
import "../src/factory/DAOWrappedTokenFactory.sol";
import "../src/factory/OnChainProposerFactory.sol";

contract IntegrationTest is Test {
    enum VoteType {
        Against,
        For,
        Abstain
    }

    SimpleGovernorFactory governorFactory;
    DAOTokenFactory tokenFactory;
    DAOWrappedTokenFactory wrappedTokenFactory;
    OnChainProposerFactory proposerFactory;
    DAOFactory factory;

    SimpleGovernor dao;
    DAOToken token;
    OnChainProposer proposer;

    address deployer;

    function setUp() public {
        deployer = address(0x123);
        vm.startPrank(deployer);

        // Create factory
        governorFactory = new SimpleGovernorFactory();
        tokenFactory = new DAOTokenFactory();
        wrappedTokenFactory = new DAOWrappedTokenFactory();
        proposerFactory = new OnChainProposerFactory();
        factory = new DAOFactory(
            ISimpleGovernorFactory(address(governorFactory)),
            IDAOTokenFactory(address(tokenFactory)),
            IDAOWrappedTokenFactory(address(wrappedTokenFactory)),
            IOnChainProposerFactory(address(proposerFactory))
        );

        // Dao arguments
        DaoData memory data = DaoData({
            name: "daoTest",
            description: "daoDescription",
            image: "daoImage"
        });
        DaoToken memory tokenInfo = DaoToken({
            name: "Test",
            symbol: "TST",
            initialSupply: 1000000
        });
        DaoParams memory params = DaoParams({
            quorumFraction: 40,
            votingDelay: 0,
            votingPeriod: 360
        });
        DaoProposer memory proposerInfo = DaoProposer({
            minimalVotingPower: 1000
        });

        // Create a DAO
        (
            address daoAddress,
            address tokenAddress,
            address proposerAddress
        ) = factory.createDAONewToken(data, tokenInfo, params, proposerInfo);
        dao = SimpleGovernor(payable(daoAddress));
        token = DAOToken(tokenAddress);
        proposer = OnChainProposer(proposerAddress);

        // Delegate voting power to the deployer
        token.delegate(deployer);

        vm.stopPrank();
    }

    function testVoteAndRejectProposal() public {
        vm.startPrank(deployer);
        vm.roll(10);

        // Create a proposal
        (
            address[] memory targets,
            uint256[] memory values,
            bytes[] memory calldatas,
            string memory description
        ) = _transferProposal();
        uint256 proposalId = proposer.propose(
            targets,
            values,
            calldatas,
            description
        );
        assertEq(
            uint(dao.state(proposalId)),
            uint(IGovernor.ProposalState.Pending)
        );
        _mine(10);
        assertEq(
            uint(dao.state(proposalId)),
            uint(IGovernor.ProposalState.Active)
        );

        // Assert start and end date of the proposal
        assertEq(dao.proposalSnapshot(proposalId), 10);
        assertEq(dao.proposalDeadline(proposalId), 370);

        // Vote on the proposal
        assertFalse(dao.hasVoted(proposalId, deployer));
        dao.castVote(proposalId, uint8(VoteType.Against));
        assertTrue(dao.hasVoted(proposalId, deployer));

        // Check proposal is rejected after voting period
        _mine(1000);
        assertEq(
            uint(dao.state(proposalId)),
            uint(IGovernor.ProposalState.Defeated)
        );

        (uint256 againstVotes, uint256 forVotes, uint256 abstainVotes) = dao
            .proposalVotes(proposalId);
        assertEq(againstVotes, 1000000);
        assertEq(forVotes, 0);
        assertEq(abstainVotes, 0);
    }

    function testVoteApproveAndExecuteProposal() public {
        vm.startPrank(deployer);

        // Send some tokens to the DAO
        token.transfer(address(dao), 50);

        // Create a proposal
        (
            address[] memory targets,
            uint256[] memory values,
            bytes[] memory calldatas,
            string memory description
        ) = _transferTokensProposal(address(token));
        uint256 proposalId = proposer.propose(
            targets,
            values,
            calldatas,
            description
        );
        _mine(10);

        // Vote on the proposal
        assertFalse(dao.hasVoted(proposalId, deployer));
        dao.castVote(proposalId, uint8(VoteType.For));

        // Check proposal is approved after voting period
        _mine(1000);
        assertEq(
            uint(dao.state(proposalId)),
            uint(IGovernor.ProposalState.Succeeded)
        );

        // Check proposal can be executed
        assertEq(token.balanceOf(address(0x456)), 0);
        dao.execute(
            targets,
            values,
            calldatas,
            bytes32(keccak256(abi.encodePacked(description)))
        );
        assertEq(
            uint(dao.state(proposalId)),
            uint(IGovernor.ProposalState.Executed)
        );
        assertEq(token.balanceOf(address(0x456)), 42);
    }

    function _transferProposal()
        internal
        pure
        returns (
            address[] memory targets,
            uint256[] memory values,
            bytes[] memory calldatas,
            string memory description
        )
    {
        targets = new address[](1);
        targets[0] = address(0x123);
        values = new uint256[](1);
        values[0] = 42;
        calldatas = new bytes[](1);
        calldatas[0] = "0x";
        description = "test";

        return (targets, values, calldatas, description);
    }

    function _transferTokensProposal(
        address _token
    )
        internal
        pure
        returns (
            address[] memory targets,
            uint256[] memory values,
            bytes[] memory calldatas,
            string memory description
        )
    {
        targets = new address[](1);
        targets[0] = _token;
        values = new uint256[](1);
        values[0] = 0;
        calldatas = new bytes[](1);
        calldatas[0] = abi.encodeWithSignature(
            "transfer(address,uint256)",
            address(0x456),
            42
        );
        description = "test";

        return (targets, values, calldatas, description);
    }

    function _mine(uint256 blocks) internal {
        vm.roll(block.number + blocks);
    }
}
