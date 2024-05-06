// SPDX-License-Identifier: APACHE-2.0
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./DAOToken.sol";

/**
 * @title DAOWrappedToken
 * @dev Governance token that represents an existing token wrapped
 */
contract DAOWrappedToken is ERC20, ERC20Permit, ERC20Votes, ERC4626 {
    constructor(
        ERC20 _token
    )
        ERC20(
            string.concat(_token.name(), " DAO token"),
            string.concat("dao", _token.symbol())
        )
        ERC20Permit(string.concat(_token.name(), " DAO token"))
        ERC4626(_token)
    {}

    function votingModuleType() public pure returns (uint8) {
        return 1;
    }

    function decimals()
        public
        pure
        virtual
        override(ERC20, ERC4626)
        returns (uint8)
    {
        return DAOTOKEN_DECIMALS;
    }

    // The functions below reimplement deposit and minting logic from ERC4626
    // by adding automatic delegation in case the receiver is the sender
    function deposit(
        uint256 assets,
        address receiver
    ) public virtual override returns (uint256) {
        uint256 deposited = super.deposit(assets, receiver);

        if (receiver == msg.sender) {
            delegate(receiver);
        }

        return deposited;
    }

    function mint(
        uint256 shares,
        address receiver
    ) public virtual override returns (uint256) {
        uint256 minted = super.mint(shares, receiver);

        if (receiver == msg.sender) {
            delegate(receiver);
        }

        return minted;
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
