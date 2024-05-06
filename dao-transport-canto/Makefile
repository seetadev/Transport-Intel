.DEFAULT_GOAL := none

.PHONY: none
none:
	$(error Please specify a target)

# For local scripts, use:
# export PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

.PHONY: deploy-factory-dry
deploy-factory-dry:
	forge script script/DAOFactory.s.sol:DAOFactoryScript

.PHONY: deploy-factory-local
deploy-factory-local:
	forge script script/DAOFactory.s.sol:DAOFactoryScript -f http://0.0.0.0:8545 --chain-id 1337 --broadcast

.PHONY: deploy-factory-arbitrum
deploy-factory-arbitrum:
	forge script script/DAOFactory.s.sol:DAOFactoryScript -f https://arb1.arbitrum.io/rpc --chain-id 42161 --broadcast

.PHONY: network
network:
	anvil --chain-id 1337

.PHONY: mine
mine:
	number=1 ; while [[ $$number -le 500 ]] ; do \
        cast rpc evm_mine ; \
        ((number = number + 1)) ; \
    done

.PHONY: build
build:
	forge build

.PHONY: test
test:
	forge test

.PHONY: clean
clean:
	rm -rf out

.PHONY: types
types:
	npx typechain --target ethers-v5 \
	out/DAOFactory.sol/DAOFactory.json \
	out/DAOGovernor.sol/DAOGovernor.json \
	out/DAOToken.sol/DAOToken.json \
	out/DAOWrappedToken.sol/DAOWrappedToken.json \
	out/DAOProposer.sol/DAOProposer.json \
