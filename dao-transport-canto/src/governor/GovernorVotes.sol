// SPDX-License-Identifier: APACHE-2.0
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/utils/IVotes.sol";

abstract contract GovernorVotes is Governor {
    IVotes public votingModule;

    constructor(IVotes _votingModule) {
        votingModule = _votingModule;
    }

    function _getVotes(
        address account,
        uint256 blockNumber,
        bytes memory /*params*/
    ) internal view virtual override returns (uint256) {
        return votingModule.getPastVotes(account, blockNumber);
    }
}
