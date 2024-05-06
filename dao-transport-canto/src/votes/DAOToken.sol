// SPDX-License-Identifier: APACHE-2.0
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

uint8 constant DAOTOKEN_DECIMALS = 18;

/**
 * @title DAOToken
 * @dev A regular ERC20 token with voting power and mintable by the owner
 */
contract DAOToken is ERC20, ERC20Permit, ERC20Votes, Ownable {
    constructor(
        string memory _name,
        string memory _symbol,
        address _fundedAddress,
        uint256 _initialSupply
    ) ERC20(_name, _symbol) ERC20Permit(_name) {
        _mint(_fundedAddress, _initialSupply);
    }

    function votingModuleType() public pure returns (uint8) {
        return 0;
    }

    function decimals() public pure virtual override(ERC20) returns (uint8) {
        return DAOTOKEN_DECIMALS;
    }

    function mint(uint256 amount) public onlyOwner {
        _mint(owner(), amount);
    }

    // The functions below are overrides required by Solidity
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        super._mint(to, amount);
    }

    function _burn(
        address account,
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        super._burn(account, amount);
    }
}
