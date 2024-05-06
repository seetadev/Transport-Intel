// SPDX-License-Identifier: APACHE-2.0
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";

import "../../src/votes/DAOWrappedToken.sol";
import "../mocks/Token.sol";

contract DAOWrappedTokenTest is Test {
    TokenMock assetToken;
    DAOWrappedToken token;

    function setUp() public {
        assetToken = new TokenMock("Asset", "AST");
        assetToken.mint(address(0x456), 1000);

        token = new DAOWrappedToken(assetToken);
    }

    function testInstantiated() public {
        assertEq(token.name(), "Asset DAO token");
        assertEq(token.symbol(), "daoAST");
        assertEq(token.totalSupply(), 0);
        assertEq(token.asset(), address(assetToken));
        assertEq(token.votingModuleType(), 1);
    }

    function testCanMintTokenAndDelegate() public {
        vm.startPrank(address(0x456));
        assetToken.approve(address(token), 1000000);
        token.mint(100, address(0x456));

        assertEq(token.totalSupply(), 100);
        assertEq(token.balanceOf(address(0x456)), 100);
        assertEq(assetToken.balanceOf(address(0x456)), 900);

        // Check voting power is automatically delegated
        assertEq(token.getVotes(address(0x456)), 100);
    }

    function testCanMintTokenForOther() public {
        vm.startPrank(address(0x456));
        assetToken.approve(address(token), 1000000);
        token.mint(100, address(0x789));

        assertEq(token.totalSupply(), 100);
        assertEq(token.balanceOf(address(0x789)), 100);
        assertEq(assetToken.balanceOf(address(0x456)), 900);

        // Vote not delegated if not self
        assertEq(token.getVotes(address(0x789)), 0);
    }

    function testCanDepositTokenAndDelegate() public {
        vm.startPrank(address(0x456));
        assetToken.approve(address(token), 1000000);
        token.deposit(100, address(0x456));

        assertEq(token.totalSupply(), 100);
        assertEq(token.balanceOf(address(0x456)), 100);
        assertEq(assetToken.balanceOf(address(0x456)), 900);

        // Check voting power is automatically delegated
        assertEq(token.getVotes(address(0x456)), 100);
    }

    function testCanDepositTokenForOther() public {
        vm.startPrank(address(0x456));
        assetToken.approve(address(token), 1000000);
        token.deposit(100, address(0x789));

        assertEq(token.totalSupply(), 100);
        assertEq(token.balanceOf(address(0x789)), 100);
        assertEq(assetToken.balanceOf(address(0x456)), 900);

        // Vote not delegated if not self
        assertEq(token.getVotes(address(0x789)), 0);
    }
}
