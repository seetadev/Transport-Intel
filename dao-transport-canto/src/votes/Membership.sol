// SPDX-License-Identifier: APACHE-2.0
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/governance/utils/Votes.sol";

/**
 * @title Membership
 * @dev Membership is a voting module owner by an admin controlling membership and voting power
 * Members are added by the admin with a voting power of 1
 * The voting power of a member can be increased by the admin
 */
contract Membership is Ownable, Votes {
    mapping(address => uint256) public memberVotes;

    /**
     * @dev Constructor
     * @param _owner Owner who controls membership and voting power
     */
    constructor(address _owner) EIP712("VoteControl", "0.1.0") {
        _transferOwnership(_owner);
    }

    /**
     * @dev Add a member
     * @param member Member to add
     */
    function addMember(address member) external onlyOwner {
        require(memberVotes[member] == 0, "Member already added");
        memberVotes[member] = 1;
        _transferVotingUnits(address(0), member, 1);

        // auto delegate to self for available voting power
        _delegate(member, member);
    }

    /**
     * @dev Remove a member
     * @param member Member to remove
     */
    function removeMember(address member) external onlyOwner {
        require(memberVotes[member] != 0, "Member not found");
        _transferVotingUnits(member, address(0), memberVotes[member]);
        memberVotes[member] = 0;
        _delegate(member, member);
    }

    /**
     * @dev Increase the voting power of a member
     * @param member Member to increase the voting power of
     * @param number Number to increase the voting power by
     */
    function increaseVotingPower(
        address member,
        uint256 number
    ) external onlyOwner {
        require(memberVotes[member] != 0, "Member not found");
        memberVotes[member] += number;

        _transferVotingUnits(address(0), member, number);
    }

    /**
     * @dev Decrease the voting power of a member
     * @param member Member to decrease the voting power of
     * @param number Number to decrease the voting power by
     */
    function decreaseVotingPower(
        address member,
        uint256 number
    ) external onlyOwner {
        require(memberVotes[member] != 0, "Member not found");
        require(memberVotes[member] > number, "Decrease too high");
        _transferVotingUnits(member, address(0), number);
        memberVotes[member] -= number;
        _delegate(member, member);
    }

    /**
     * Disable delegation methods
     */
    function delegate(address) public pure override {
        revert("Delegation not supported");
    }

    function delegateBySig(
        address,
        uint256,
        uint256,
        uint8,
        bytes32,
        bytes32
    ) public pure override {
        revert("Delegation not supported");
    }

    /**
     * @dev Get the voting power of a member
     * @param member Member to get the voting power of
     * @return Voting power of the member
     */
    function _getVotingUnits(
        address member
    ) internal view virtual override returns (uint256) {
        return memberVotes[member];
    }
}
