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

    const witnetPriceRouterAddresses: { [network: string]: string } = {
        mainnet: '0xD39D4d972C7E166856c4eb29E54D3548B4597F53',
        testnet: '0xba7CF62498340fa3734EC51Ca8A69928F0d9E03a',
        hardhat: '0x0000000000000000000000000000000000000000',
        localhost: '0x0000000000000000000000000000000000000000',
    };

    console.log(witnetPriceRouterAddresses[hre.network.name]);
    const knsPriceOracle = await deploy('KNSPriceOracle', {
        from: deployers[0],
        args: [witnetPriceRouterAddresses[hre.network.name]],
        log: true,
        autoMine: true, // speed up deployment on local network (ganache, hardhat), no effect on live networks
    });

    const knsRegistrarController = await deploy('KNSRegistrarController', {
        from: deployers[0],
        args: [knsRegistrarAddress, knsReverseRegistrarAddress],
        log: true,
        autoMine: true, // speed up deployment on local network (ganache, hardhat), no effect on live networks
    });

    const knsRegistrarControllerContract = await hre.ethers.getContractAt(knsRegistrarController.abi, knsRegistrarController.address);
    let tx = await knsRegistrarControllerContract.setPriceOracle(knsPriceOracle.address);
    await tx.wait();

    const knsRegistrarContract = await hre.ethers.getContractAt(knsRegistrar.abi, knsRegistrarAddress);
    tx = await knsRegistrarContract.addController(knsRegistrarController.address);
    await tx.wait();

    const knsReverseRegistrarContract = await hre.ethers.getContractAt(knsReverseRegistrar.abi, knsReverseRegistrarAddress);
    tx = await knsReverseRegistrarContract.setController(knsRegistrarController.address, true);
    await tx.wait();

    const knsResolverContract = await hre.ethers.getContractAt(knsPublicResolver.abi, knsPublicResolverAddress);
    tx = await knsResolverContract.setController(knsRegistrarController.address, true);
    await tx.wait();

    const eligibleCollections: { [network: string]: string[] } = {
        mainnet: ["0x4Ca64bF392ee736f6007Ce93E022DeB471a9dFd1", "0x2Ca9eE122915E76A9e64F0c2EeB8C233397Ed248"],
        testnet: ["0x0cc98AF4316150F7BBC96B2250aaf4E9d7f9f3AB"],
    }

    const knsPriceOracleContract = await hre.ethers.getContractAt(knsPriceOracle.abi, knsPriceOracle.address);
    for (const collection of eligibleCollections[hre.network.name]) {
        tx = await knsPriceOracleContract.addEligibleCollection(collection);
        await tx.wait();
    }

    console.log("registering names");
    const names: string[] = [
        "mojitoswap",
        "kuswap",
        "kudoge",
        "tiku",
        "kupay",
        "tokenmerch",
        "heroesvale",
        "dextools",
        "openleverage",
        "pencildao",
        "vixenpunks",
        "zeedex",
        "kukitty",
        "ksfswap",
        "kuflame",
        "kardia",
        "elkfinance",
        "saffron",
        "bitkeep",
        "lomen",
    ]
    for (const name of names) {
        tx = await knsRegistrarControllerContract.register(name, deployers[0], knsPublicResolverAddress, deployers[0], true);
        await tx.wait();
    }

    return hre.network.live; // when live network, record the script as executed to prevent rexecution
};

func.id = 'deploy_kns_deployer'; // id required to prevent reexecution
func.tags = ['KNSDeployer'];

export default func;
