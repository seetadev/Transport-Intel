// SPDX-License-Identifier: APACHE-2.0
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../src/factory/SimpleGovernorFactory.sol";
import "../src/factory/DAOTokenFactory.sol";
import "../src/factory/DAOWrappedTokenFactory.sol";
import "../src/factory/OnChainProposerFactory.sol";
import "../src/factory/DAOFactory.sol";

// DAOFactory script
contract DAOFactoryScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy factories
        SimpleGovernorFactory governorFactory = new SimpleGovernorFactory();
        DAOTokenFactory tokenFactory = new DAOTokenFactory();
        DAOWrappedTokenFactory wrappedTokenFactory = new DAOWrappedTokenFactory();
        OnChainProposerFactory proposerFactory = new OnChainProposerFactory();

        // Deploy DAOFactory
        DAOFactory daoFactory = new DAOFactory(
            ISimpleGovernorFactory(address(governorFactory)),
            IDAOTokenFactory(address(tokenFactory)),
            IDAOWrappedTokenFactory(address(wrappedTokenFactory)),
            IOnChainProposerFactory(address(proposerFactory))
        );
        daoFactory = daoFactory;

        vm.stopBroadcast();
    }
}
