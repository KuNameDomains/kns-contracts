#!/bin/sh

# TODO: automatically get the remaps from foundry.toml
sudo umount ./@ds/
sudo umount ./@std/
sudo umount ./@rari-capital/solmate/
sudo umount ./@clones/
sudo umount ./@ensdomains/buffer/
sudo umount ./@ensdomains/ens-contracts/
sudo umount ./@openzeppelin/
rm -r ./@*
