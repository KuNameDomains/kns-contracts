import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction, DeploymentSubmission } from 'hardhat-deploy/types';

const func: DeployFunction = async function(hre: HardhatRuntimeEnvironment) {
    const deployers = await hre.getUnnamedAccounts();
    const { deploy } = hre.deployments;

    const namehashDBAddress = await hre.deployments.read('NamehashDBDeployer', 'namehashDB');

    await deploy('KNSDeployer', {
        from: deployers[0],
        args: [namehashDBAddress],
        log: true,
        autoMine: true, // speed up deployment on local network (ganache, hardhat), no effect on live networks
    });

    const knsRegistryAddress = await hre.deployments.read('KNSDeployer', 'registry');
    const knsRegistry = await hre.deployments.getArtifact('KNSRegistry');
    hre.deployments.save(knsRegistry.contractName, {
        abi: knsRegistry.abi,
        address: knsRegistryAddress,
    } as DeploymentSubmission);

    const knsRegistrarAddress = await hre.deployments.read('KNSDeployer', 'registrar');
    const knsRegistrar = await hre.deployments.getArtifact('KNSRegistrar');
    hre.deployments.save(knsRegistrar.contractName, {
        abi: knsRegistrar.abi,
        address: knsRegistrarAddress,
    } as DeploymentSubmission);

    const knsPublicResolverAddress = await hre.deployments.read('KNSDeployer', 'publicResolver');
    const knsPublicResolver = await hre.deployments.getArtifact('KNSPublicResolver');
    hre.deployments.save(knsPublicResolver.contractName, {
        abi: knsPublicResolver.abi,
        address: knsPublicResolverAddress,
    } as DeploymentSubmission);

    const knsReverseRegistrarAddress = await hre.deployments.read('KNSDeployer', 'reverseRegistrar');
    const knsReverseRegistrar = await hre.deployments.getArtifact('KNSReverseRegistrar');
    hre.deployments.save(knsReverseRegistrar.contractName, {
        abi: knsReverseRegistrar.abi,
        address: knsReverseRegistrarAddress,
    } as DeploymentSubmission);

    const knsRegistrarControllerAddress = await hre.deployments.read('KNSDeployer', 'controller');
    const knsRegistrarController = await hre.deployments.getArtifact('KNSRegistrarController');
    hre.deployments.save(knsRegistrarController.contractName, {
        abi: knsRegistrarController.abi,
        address: knsRegistrarControllerAddress,
    } as DeploymentSubmission);

    return hre.network.live; // when live network, record the script as executed to prevent rexecution
};

func.id = 'deploy_kns_deployer'; // id required to prevent reexecution
func.tags = ['KNSDeployer'];

export default func;