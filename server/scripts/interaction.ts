
import { CallData, constants, RpcProvider, Contract, Account, json, ec, cairo } from "starknet";
import fs from "fs";
import * as dotenv from "dotenv";
import { getCompiledCode } from "./utils";
dotenv.config();


async function main() {
    //initialize Provider 
    const provider = new RpcProvider({
        nodeUrl: process.env.RPC_ENDPOINT,
      });

    // initialize existing Argent X account
    const privateKey0 = process.env.DEPLOYER_PRIVATE_KEY ?? "";
    const accountAddress0: string = process.env.DEPLOYER_ADDRESS ?? "";
    const account0 = new Account(provider, accountAddress0,privateKey0);
    console.log('existing AX account1 connected.\n');


    // Connect the deployed Test instance in devnet
    const testAddress = "0x6864e2cf07e16f006b7de9c0a3822f30382005f547b3dbb25285d80203c30ad"; // modify in accordance with result of script 4
    const compiledTest = json.parse(fs.readFileSync("target/dev/uno_game_UnoGameContract.contract_class.json").toString("ascii"));
    const myTestContract = new Contract(compiledTest.abi, testAddress, provider);
    console.log('Test Contract connected at =', myTestContract.address);

    // Interactions with the contract with call & invoke
    myTestContract.connect(account0);
    const par1 = CallData.compile({
        balance: 100,
    })

    const create_game_req = CallData.compile({
        max_players: 2
    })

    
    const res1 = await myTestContract.create_game(create_game_req);
   
    // const tx = await myTestContract.increase_balance(
    //     CallData.compile({
    //         amount: 100,
    //     })
    // );
    // 🚨 do not work in V5.1.0
    //const bal1b = await myTestContract.call("get_balance");
    console.log("res1 =", res1);
 
    // await provider.waitForTransaction(tx.transaction_hash);

    // const balance = await myTestContract.get_counter({
    //     parseRequest: false,
    //     parseResponse: false,
    // });
    // console.log("res4 =", balance);
    // console.log("Initial balance =", bal1b.res.toString());
    // estimate fee
    // const { suggestedMaxFee: estimatedFee1 } = await account0.estimateInvokeFee({ contractAddress: testAddress, entrypoint: "increase_balance", calldata: ["10", "30"] });

    // const resu = await myTestContract.invoke("increase_balance", [10, 30]);
    // await provider.waitForTransaction(resu.transaction_hash);
    // const bal2 = await myTestContract.get_balance();
    // console.log("Initial balance =", bal2.res.toString());
    console.log('✅ Test completed.');

}
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });

    // let success = await connection.execute([
    //     {
    //         contractAddress: erc20_address,
    //         entrypoint: 'approve',
    //         calldata: CallData.compile({
    //         recipient : core_address,
    //         amount: cairo.uint256(amount)	
    //         }),
    //     }, 
    //     {
    //         contractAddress: core_address,
    //         entrypoint: 'deposit',
    //         calldata: CallData.compile({
    //         amount: cairo.uint256(amount)	,
    //         hash : hash,
            
    //         }),
    //     }
    // ])