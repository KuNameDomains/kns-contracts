import '@nomiclabs/hardhat-ethers';
import '@typechain/hardhat';

import { HardhatUserConfig } from 'hardhat/types';


const config: HardhatUserConfig = {
    solidity: {
        compilers: [
            {
                version: '0.8.13',
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 666,
                    },
                },
            },
        ],
    },
    paths: {
        sources: 'src',
        artifacts: 'out',
    },
    typechain: {
        outDir: 'typechain',
        target: 'ethers-v5',
    },
};

export default config;
