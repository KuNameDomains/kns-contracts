#!/bin/sh

# TODO: automatically get the remaps from foundry.toml
mkdir -p ./@ds/ && sudo mount --bind ./lib/ds-test/src/ ./@ds/
mkdir -p ./@std/ && sudo mount --bind ./lib/forge-std/src/ ./@std/
mkdir -p ./@rari-capital/solmate/ && sudo mount --bind ./lib/solmate/src/ ./@rari-capital/solmate/
mkdir -p ./@clones/ && sudo mount --bind ./lib/clones-with-immutable-args/src/ ./@clones/
mkdir -p ./@ensdomains/buffer/ && sudo mount --bind ./lib/buffer/ ./@ensdomains/buffer/
mkdir -p ./@ensdomains/ens-contracts/ && sudo mount --bind ./lib/ens-contracts/ ./@ensdomains/ens-contracts/
mkdir -p ./@openzeppelin/ && sudo mount --bind ./lib/openzeppelin-contracts/ ./@openzeppelin/
