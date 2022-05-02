import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/types';

const func: DeployFunction = async function(hre: HardhatRuntimeEnvironment) {
    const deployers = await hre.getUnnamedAccounts();
    const { deploy } = hre.deployments;

    const knsRegistryAddress = await hre.deployments.read('KNSDeployer', 'registry');
    const namehashDBAddress = await hre.deployments.read('KNSDeployer', 'namehashDB');

    await deploy('KNSMultifetcher', {
        from: deployers[0],
        args: [knsRegistryAddress, namehashDBAddress],
        log: true,
        autoMine: true, // speed up deployment on local network (ganache, hardhat), no effect on live networks
    });

    return hre.network.live; // when live network, record the script as executed to prevent rexecution
};

func.id = 'deploy_kns_multifetcher'; // id required to prevent reexecution
func.tags = ['KNSMultifetcher'];

export default func;
