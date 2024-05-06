// SPDX-License-Identifier: APACHE-2.0
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";

import "../../src/votes/DAOToken.sol";

contract DAOTokenTest is Test {
    DAOToken token;
    address funded;

    function setUp() public {
        funded = msg.sender;
        token = new DAOToken("Test", "TST", funded, 1000000);
    }

    function testInstantiated() public {
        assertEq(token.name(), "Test");
        assertEq(token.symbol(), "TST");
        assertEq(token.totalSupply(), 1000000);
        assertEq(token.balanceOf(funded), 1000000);
        assertEq(token.votingModuleType(), 0);
    }

    function testCanMint() public {
        uint256 balance = token.balanceOf(token.owner());
        token.mint(1000);
        assertEq(token.balanceOf(token.owner()), balance + 1000);
    }

    function testFailNonOwnerMint() public {
        vm.prank(address(0));
        token.mint(1000);
    }
}
