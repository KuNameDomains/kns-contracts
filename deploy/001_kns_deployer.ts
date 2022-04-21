import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction, DeploymentSubmission } from 'hardhat-deploy/types';

const func: DeployFunction = async function(hre: HardhatRuntimeEnvironment) {
    const deployers = await hre.getUnnamedAccounts();
    const { deploy } = hre.deployments;

    await deploy('KNSDeployer', {
        from: deployers[0],
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

    const namehashDBAddress = await hre.deployments.read('KNSDeployer', 'namehashDB');
    const namehashDB = await hre.deployments.getArtifact('NamehashDB');
    hre.deployments.save(namehashDB.contractName, {
        abi: namehashDB.abi,
        address: namehashDBAddress,
    } as DeploymentSubmission);

    const fifoRegistrarControllerAddress = await hre.deployments.read('KNSDeployer', 'fifoRegistrarController');
    const fifoRegistrarController = await hre.deployments.getArtifact('FIFORegistrarController');
    hre.deployments.save(fifoRegistrarController.contractName, {
        abi: fifoRegistrarController.abi,
        address: fifoRegistrarControllerAddress,
    } as DeploymentSubmission);

    return hre.network.live; // when live network, record the script as executed to prevent rexecution
};

func.id = 'deploy_kns_deployer'; // id required to prevent reexecution
func.tags = ['KNSDeployer'];

export default func;
