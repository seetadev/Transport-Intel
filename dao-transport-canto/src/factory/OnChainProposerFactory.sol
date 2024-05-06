// SPDX-License-Identifier: APACHE-2.0
pragma solidity ^0.8.17;

import "../proposer/OnChainProposer.sol";

interface IOnChainProposerFactory {
    function deployProposer(uint256) external returns (address);
}

contract OnChainProposerFactory {
    function deployProposer(
        uint256 _minimalVotingPower
    ) external returns (address) {
        OnChainProposer proposer = new OnChainProposer(_minimalVotingPower);
        return address(proposer);
    }
}
