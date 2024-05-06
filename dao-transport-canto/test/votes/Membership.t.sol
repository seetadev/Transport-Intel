// SPDX-License-Identifier: APACHE-2.0
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

import "../../src/votes/Membership.sol";

contract MembershipTest is Test {
    address admin;
    Membership membership;

    function setUp() public {
        admin = msg.sender;
        membership = new Membership(admin);

        vm.startPrank(admin);
        membership.addMember(address(0x111));
        membership.addMember(address(0x222));
        membership.increaseVotingPower(address(0x222), 100);
        vm.stopPrank();
    }

    function testInstantiated() public {
        assertEq(membership.owner(), admin);
    }

    function testAdminAddMember() public {
        vm.startPrank(admin);
        membership.addMember(address(0x456));
        assertEq(membership.getVotes(address(0x456)), 1);
    }

    function testFailNonAdminAddMember() public {
        vm.startPrank(address(0x456));
        membership.addMember(address(0x456));
    }

    function testFailAddExistingMember() public {
        vm.startPrank(admin);
        membership.addMember(address(0x111));
    }

    function testAdminRemoveMember() public {
        vm.startPrank(admin);
        membership.removeMember(address(0x111));
        assertEq(membership.getVotes(address(0x111)), 0);
    }

    function testFailNonAdminRemoveMember() public {
        vm.startPrank(address(0x456));
        membership.removeMember(address(0x111));
    }

    function testFailRemoveNonMember() public {
        vm.startPrank(admin);
        membership.removeMember(address(0x456));
    }

    function testAdminIncreaseVotingPower() public {
        vm.startPrank(admin);
        membership.increaseVotingPower(address(0x111), 100);
        assertEq(membership.getVotes(address(0x111)), 101);

        membership.increaseVotingPower(address(0x111), 100);
        assertEq(membership.getVotes(address(0x111)), 201);
    }

    function testFailNonAdminIncreaseVotingPower() public {
        vm.startPrank(address(0x456));
        membership.increaseVotingPower(address(0x111), 100);
    }

    function testFailIncreaseVotingPowerNonMember() public {
        vm.startPrank(admin);
        membership.increaseVotingPower(address(0x456), 100);
    }

    function testAdminDecreaseVotingPower() public {
        vm.startPrank(admin);
        membership.decreaseVotingPower(address(0x222), 50);
        assertEq(membership.getVotes(address(0x222)), 51);
    }

    function testFailNonAdminDecreaseVotingPower() public {
        vm.startPrank(address(0x456));
        membership.decreaseVotingPower(address(0x222), 50);
    }

    function testFailDecreaseVotingPowerNonMember() public {
        vm.startPrank(admin);
        membership.decreaseVotingPower(address(0x456), 50);
    }

    function testFailDecreaseVotingPowerToZero() public {
        vm.startPrank(admin);
        membership.decreaseVotingPower(address(0x222), 101);
    }

    function testFailDelegate() public {
        vm.startPrank(address(0x111));
        membership.delegate(address(0x456));
    }
}
