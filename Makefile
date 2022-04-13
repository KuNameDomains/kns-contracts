# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env


.PHONY: all
all: clean install update solc build

# Install proper solc version using solc-select
.PHONY: solc
solc:;
	pip3 install solc-select
	solc-select install 0.8.13
	solc-select use 0.8.13

.PHONY: clean
clean  :; forge clean

.PHONY: install
install :; forge install

.PHONY: update
update:; forge update

.PHONY: build
build  :; forge clean && forge build --optimize --optimize-runs 666

.PHONY: scripts
scripts :; chmod +x ./scripts/*

.PHONY: test
test   :; forge clean && forge test --optimize --optimize-runs 666 -v # --ffi # enable if you need the `ffi` cheat code on HEVM

.PHONY: lint
lint :; prettier --write src/**/*.sol && prettier --write src/*.sol

# Generate Gas Snapshots
.PHONY: snapshot
snapshot :; forge clean && forge snapshot --optimize --optimize-runs 666

# Mount deps to remaps folders in the root of the project to stop solc
# from complaining while we wait for it to support remaps/include paths
.PHONY: mount-deps
mount-deps:; ./scripts/mount_deps.sh

# Unmount previously mounted deps
.PHONY: unmount-deps
unmount-deps:; ./scripts/unmount_deps.sh
