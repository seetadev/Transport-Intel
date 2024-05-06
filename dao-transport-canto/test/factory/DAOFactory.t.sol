// SPDX-License-Identifier: APACHE-2.0
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

import "../../src/factory/DAOFactory.sol";
import "../../src/proposer/OnChainProposer.sol";
import "../../src/votes/DAOToken.sol";
import "../../src/governor/SimpleGovernor.sol";

import "../../src/factory/SimpleGovernorFactory.sol";
import "../../src/factory/DAOTokenFactory.sol";
import "../../src/factory/DAOWrappedTokenFactory.sol";
import "../../src/factory/OnChainProposerFactory.sol";

import "../mocks/Token.sol";

// Define constant for quorum fraction, voting delay, and voting period
uint256 constant quorumFraction = 40;
uint256 constant votingDelay = 0;
uint256 constant votingPeriod = 360; // around 30 minutes
uint constant minimalVotingPower = 1000;

contract DAOFactoryNewTokenTest is Test {
    TokenMock assetToken;
    SimpleGovernorFactory governorFactory;
    DAOTokenFactory tokenFactory;
    DAOWrappedTokenFactory wrappedTokenFactory;
    OnChainProposerFactory proposerFactory;
    DAOFactory factory;

    function setUp() public {
        assetToken = new TokenMock("Asset", "AST");
        assetToken.mint(address(0x123), 1000);

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
    }

    function testInstantiated() public {
        assertEq(address(factory.governorFactory()), address(governorFactory));
        assertEq(address(factory.tokenFactory()), address(tokenFactory));
        assertEq(
            address(factory.wrappedTokenFactory()),
            address(wrappedTokenFactory)
        );
        assertEq(address(factory.proposerFactory()), address(proposerFactory));
    }

    function testCanCreateDAOWithNewToken() public {
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
            quorumFraction: quorumFraction,
            votingDelay: votingDelay,
            votingPeriod: votingPeriod
        });
        DaoProposer memory proposerInfo = DaoProposer({
            minimalVotingPower: minimalVotingPower
        });
        (address dao, address token, address proposer) = factory
            .createDAONewToken(data, tokenInfo, params, proposerInfo);
        assertEq(factory.getDAOCount(), 1);
        address newDao = factory.getDAO(0);
        assertEq(newDao, dao);

        SimpleGovernor governor = SimpleGovernor(payable(dao));
        assertEq(governor.name(), "daoTest");
        assertEq(governor.description(), "daoDescription");
        assertEq(governor.imageURL(), "daoImage");
        assertEq(governor.proposer(), proposer);
        assertEq(address(governor.votingModule()), token);

        DAOToken tokenContract = DAOToken(token);
        assertEq(tokenContract.name(), "Test");
        assertEq(tokenContract.symbol(), "TST");
        assertEq(tokenContract.totalSupply(), 1000000);
        assertEq(tokenContract.owner(), dao);

        OnChainProposer proposerContract = OnChainProposer(proposer);
        assertEq(address(proposerContract.daoGovernor()), dao);
        assertEq(proposerContract.minimalVotingPower(), minimalVotingPower);

        DaoData memory data2 = DaoData({
            name: "daoTest2",
            description: "daoDescription2",
            image: "daoImage2"
        });
        DaoToken memory tokenInfo2 = DaoToken({
            name: "Test2",
            symbol: "TST2",
            initialSupply: 1000000
        });
        DaoParams memory params2 = DaoParams({
            quorumFraction: quorumFraction,
            votingDelay: votingDelay,
            votingPeriod: votingPeriod
        });
        DaoProposer memory proposerInfo2 = DaoProposer({
            minimalVotingPower: minimalVotingPower
        });

        // can create another DAO
        (dao, token, proposer) = factory.createDAONewToken(
            data2,
            tokenInfo2,
            params2,
            proposerInfo2
        );
        assertEq(factory.getDAOCount(), 2);
        newDao = factory.getDAO(1);
        assertEq(newDao, dao);

        governor = SimpleGovernor(payable(dao));
        assertEq(governor.name(), "daoTest2");
        assertEq(governor.description(), "daoDescription2");
        assertEq(governor.imageURL(), "daoImage2");
        assertEq(governor.proposer(), proposer);
        assertEq(address(governor.votingModule()), token);

        tokenContract = DAOToken(token);
        assertEq(tokenContract.name(), "Test2");
        assertEq(tokenContract.symbol(), "TST2");
        assertEq(tokenContract.totalSupply(), 1000000);
        assertEq(tokenContract.owner(), dao);

        proposerContract = OnChainProposer(proposer);
        assertEq(address(proposerContract.daoGovernor()), dao);
        assertEq(proposerContract.minimalVotingPower(), minimalVotingPower);
    }

    function testCanCreateDAOWithExistingToken() public {
        DaoData memory data = DaoData({
            name: "daoTest",
            description: "daoDescription",
            image: "daoImage"
        });
        DaoWrappedToken memory tokenInfo = DaoWrappedToken({
            assetToken: ERC20(address(assetToken))
        });
        DaoParams memory params = DaoParams({
            quorumFraction: quorumFraction,
            votingDelay: votingDelay,
            votingPeriod: votingPeriod
        });
        DaoProposer memory proposerInfo = DaoProposer({
            minimalVotingPower: minimalVotingPower
        });
        (address dao, address token, address proposer) = factory
            .createDAOExistingToken(data, tokenInfo, params, proposerInfo);
        assertEq(factory.getDAOCount(), 1);
        address newDao = factory.getDAO(0);
        assertEq(newDao, dao);

        SimpleGovernor governor = SimpleGovernor(payable(dao));
        assertEq(governor.name(), "daoTest");
        assertEq(governor.description(), "daoDescription");
        assertEq(governor.imageURL(), "daoImage");
        assertEq(governor.proposer(), proposer);
        assertEq(address(governor.votingModule()), token);

        DAOWrappedToken tokenContract = DAOWrappedToken(token);
        assertEq(tokenContract.name(), "Asset DAO token");
        assertEq(tokenContract.symbol(), "daoAST");
        assertEq(tokenContract.asset(), address(assetToken));

        OnChainProposer proposerContract = OnChainProposer(proposer);
        assertEq(address(proposerContract.daoGovernor()), dao);
        assertEq(proposerContract.minimalVotingPower(), minimalVotingPower);

        DaoData memory data2 = DaoData({
            name: "daoTest2",
            description: "daoDescription2",
            image: "daoImage2"
        });
        DaoWrappedToken memory tokenInfo2 = DaoWrappedToken({
            assetToken: ERC20(address(assetToken))
        });
        DaoParams memory params2 = DaoParams({
            quorumFraction: quorumFraction,
            votingDelay: votingDelay,
            votingPeriod: votingPeriod
        });
        DaoProposer memory proposerInfo2 = DaoProposer({
            minimalVotingPower: minimalVotingPower
        });

        // can create another DAO
        (dao, token, proposer) = factory.createDAOExistingToken(
            data2,
            tokenInfo2,
            params2,
            proposerInfo2
        );
        assertEq(factory.getDAOCount(), 2);
        newDao = factory.getDAO(1);
        assertEq(newDao, dao);

        governor = SimpleGovernor(payable(dao));
        assertEq(governor.name(), "daoTest2");
        assertEq(governor.description(), "daoDescription2");
        assertEq(governor.imageURL(), "daoImage2");
        assertEq(governor.proposer(), proposer);
        assertEq(address(governor.votingModule()), token);

        tokenContract = DAOWrappedToken(token);
        assertEq(tokenContract.name(), "Asset DAO token");
        assertEq(tokenContract.symbol(), "daoAST");
        assertEq(tokenContract.asset(), address(assetToken));

        proposerContract = OnChainProposer(proposer);
        assertEq(address(proposerContract.daoGovernor()), dao);
        assertEq(proposerContract.minimalVotingPower(), minimalVotingPower);
    }
}
