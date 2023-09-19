-include .env

build:; forge build

deploy-sepolia:
	forge script script/DeployFundMe --rpc-url $(SEPOLIA_RPC) --private-key $(PRIVATE_KEY) --broadcast