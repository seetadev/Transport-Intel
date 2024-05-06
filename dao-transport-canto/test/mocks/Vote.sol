// SPDX-License-Identifier: APACHE-2.0
pragma solidity ^0.8.17;

contract VoteMock {
    address public delegated = address(0);
    uint256 public pastTotalSupply = 0;
    uint256 public pastVotes = 0;
    uint256 public votes = 0;

    function setPastTotalSupply(uint256 _pastTotalSupply) external {
        pastTotalSupply = _pastTotalSupply;
    }

    function setPastVotes(uint256 _pastVotes) external {
        pastVotes = _pastVotes;
    }

    function setVotes(uint256 _votes) external {
        votes = _votes;
    }

    function setDelegated(address _delegated) external {
        delegated = _delegated;
    }

    function getVotes(address account) external view returns (uint256) {
        account = account;
        return votes;
    }

    function getPastVotes(
        address account,
        uint256 timepoint
    ) external view returns (uint256) {
        account = account;
        timepoint = timepoint;
        return pastVotes;
    }

    function getPastTotalSupply(
        uint256 timepoint
    ) external view returns (uint256) {
        timepoint = timepoint;
        return pastTotalSupply;
    }

    function delegates(address account) external view returns (address) {
        account = account;
        return delegated;
    }

    function delegate(address delegatee) external {}

    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {}
}
