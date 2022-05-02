import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/types';

const func: DeployFunction = async function(hre: HardhatRuntimeEnvironment) {
    const deployers = await hre.getUnnamedAccounts();
    const { deploy } = hre.deployments;

    await deploy('NamehashDBDeployer', {
        from: deployers[0],
        log: true,
        autoMine: true, // speed up deployment on local network (ganache, hardhat), no effect on live networks
    });

    return hre.network.live; // when live network, record the script as executed to prevent rexecution
};

func.id = 'deploy_namehashdb_deployer'; // id required to prevent reexecution
func.tags = ['NamehashDBDeployer'];

export default func;
