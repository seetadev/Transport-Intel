// SPDX-License-Identifier: APACHE-2.0
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/governance/utils/IVotes.sol";

import "../governor/SimpleGovernor.sol";

interface ISimpleGovernorFactory {
    function deployGovernor(
        string memory _daoName,
        string memory _daoDescription,
        string memory _daoImage,
        IVotes _token,
        address _proposer,
        uint256 _quorumFraction,
        uint256 _votingDelay,
        uint256 _votingPeriod
    ) external returns (SimpleGovernor);
}

contract SimpleGovernorFactory {
    function deployGovernor(
        string memory _daoName,
        string memory _daoDescription,
        string memory _daoImage,
        IVotes _token,
        address _proposer,
        uint256 _quorumFraction,
        uint256 _votingDelay,
        uint256 _votingPeriod
    ) external returns (SimpleGovernor) {
        // Deploy the simple governor
        SimpleGovernor dao = new SimpleGovernor(
            _daoName,
            _daoDescription,
            _daoImage,
            _token,
            _proposer,
            _quorumFraction,
            _votingDelay,
            _votingPeriod
        );

        return SimpleGovernor(dao);
    }
}
