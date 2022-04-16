import 'dotenv/config';
import 'hardhat-deploy';
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
    networks: {
        localhost: {
            live: false,
            saveDeployments: true,
        },
        hardhat: {
            live: false,
            saveDeployments: true,
        },
        testnet: {
            live: true,
            url: process.env.TESTNET_RPC_URL,
            accounts: [process.env.TESTNET_PRIVATE_KEY ?? ''],
            saveDeployments: true,
        },
        mainnet: {
            live: true,
            url: process.env.MAINNET_RPC_URL,
            accounts: [process.env.MAINNET_PRIVATE_KEY ?? ''],
            saveDeployments: true,
        },
    }
};

export default config;
