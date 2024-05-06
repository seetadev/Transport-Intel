// SPDX-License-Identifier: APACHE-2.0
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/governance/utils/IVotes.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "./SimpleGovernorFactory.sol";
import "./DAOTokenFactory.sol";
import "./DAOWrappedTokenFactory.sol";
import "./OnChainProposerFactory.sol";
import "../governor/SimpleGovernor.sol";

struct DaoData {
    string name;
    string description;
    string image;
}

struct DaoToken {
    string name;
    string symbol;
    uint256 initialSupply;
}

struct DaoWrappedToken {
    ERC20 assetToken;
}

struct DaoParams {
    uint256 quorumFraction;
    uint256 votingDelay;
    uint256 votingPeriod;
}

struct DaoProposer {
    uint256 minimalVotingPower;
}

contract DAOFactory {
    // Factory contracts
    ISimpleGovernorFactory public governorFactory;
    IDAOTokenFactory public tokenFactory;
    IDAOWrappedTokenFactory public wrappedTokenFactory;
    IOnChainProposerFactory public proposerFactory;

    address[] public daos;

    event DAOCreated(address indexed deployer, address dao);

    constructor(
        ISimpleGovernorFactory _governorFactory,
        IDAOTokenFactory _tokenFactory,
        IDAOWrappedTokenFactory _wrappedTokenFactory,
        IOnChainProposerFactory _proposerFactory
    ) {
        governorFactory = _governorFactory;
        tokenFactory = _tokenFactory;
        wrappedTokenFactory = _wrappedTokenFactory;
        proposerFactory = _proposerFactory;
    }

    // Get a DAO from its index
    function getDAO(uint256 _index) external view returns (address) {
        return daos[_index];
    }

    // Get the number of DAOs
    function getDAOCount() external view returns (uint256) {
        return daos.length;
    }

    function createDAONewToken(
        DaoData memory _data,
        DaoToken memory _token,
        DaoParams memory _params,
        DaoProposer memory _proposer
    ) external returns (address, address, address) {
        // Deploy proposer
        address proposer = proposerFactory.deployProposer(
            _proposer.minimalVotingPower
        );

        // Deploy governance token
        address token = _deployToken(_token);

        // Deploy the DAO governor
        SimpleGovernor dao = _deployDao(
            _data,
            _params,
            IVotes(token),
            proposer
        );

        // Set the governor to the proposer
        IDAOProposer(proposer).setGovernor(dao);

        // Transfer ownership of the token to the DAO
        Ownable(token).transferOwnership(address(dao));

        // Add the DAO to the array of DAOs
        daos.push(address(dao));

        emit DAOCreated(msg.sender, address(dao));

        return (address(dao), address(token), address(proposer));
    }

    function createDAOExistingToken(
        DaoData memory _data,
        DaoWrappedToken memory _wrappedToken,
        DaoParams memory _params,
        DaoProposer memory _proposer
    ) external returns (address, address, address) {
        // Deploy proposer
        address proposer = proposerFactory.deployProposer(
            _proposer.minimalVotingPower
        );

        // Deploy governance token based on existing token
        address token = _deployWrappedToken(_wrappedToken);

        // Deploy the DAO governor
        SimpleGovernor dao = _deployDao(
            _data,
            _params,
            IVotes(token),
            proposer
        );

        // Set the governor to the proposer
        IDAOProposer(proposer).setGovernor(dao);

        // Add the DAO to the array of DAOs
        daos.push(address(dao));

        emit DAOCreated(msg.sender, address(dao));

        return (address(dao), address(token), address(proposer));
    }

    function _deployToken(DaoToken memory _token) internal returns (address) {
        return
            tokenFactory.deployDAOToken(
                _token.name,
                _token.symbol,
                msg.sender,
                _token.initialSupply
            );
    }

    function _deployWrappedToken(
        DaoWrappedToken memory _token
    ) internal returns (address) {
        return wrappedTokenFactory.deployDAOWrappedToken(_token.assetToken);
    }

    function _deployDao(
        DaoData memory _data,
        DaoParams memory _params,
        IVotes _token,
        address _proposer
    ) internal returns (SimpleGovernor) {
        return
            governorFactory.deployGovernor(
                _data.name,
                _data.description,
                _data.image,
                _token,
                _proposer,
                _params.quorumFraction,
                _params.votingDelay,
                _params.votingPeriod
            );
    }
}
