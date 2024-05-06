// SPDX-License-Identifier: APACHE-2.0
pragma solidity ^0.8.17;

import "../votes/DAOToken.sol";

interface IDAOTokenFactory {
    function deployDAOToken(
        string memory _name,
        string memory _symbol,
        address _fundedAddress,
        uint256 _initialSupply
    ) external returns (address);
}

contract DAOTokenFactory {
    function deployDAOToken(
        string memory _name,
        string memory _symbol,
        address _fundedAddress,
        uint256 _initialSupply
    ) external returns (address) {
        DAOToken daoToken = new DAOToken(
            _name,
            _symbol,
            _fundedAddress,
            _initialSupply
        );

        // Transfer ownership of the token to the sender
        daoToken.transferOwnership(msg.sender);

        return address(daoToken);
    }
}
