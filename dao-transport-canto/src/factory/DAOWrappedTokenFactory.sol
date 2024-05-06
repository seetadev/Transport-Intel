// SPDX-License-Identifier: APACHE-2.0
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../votes/DAOWrappedToken.sol";

interface IDAOWrappedTokenFactory {
    function deployDAOWrappedToken(
        ERC20 _assetToken
    ) external returns (address);
}

contract DAOWrappedTokenFactory {
    function deployDAOWrappedToken(
        ERC20 _assetToken
    ) external returns (address) {
        DAOWrappedToken daoWrappedToken = new DAOWrappedToken(_assetToken);

        return (address(daoWrappedToken));
    }
}
