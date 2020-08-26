# SETUP A GuildNet NODE
We provide this guild to clarify how to setup a near validator node on Guildnet for anyone who is willing to practise near project, especially for validators on Virtual Private Server such as AWS or Vultr. We demonstrate step by step even if you're a newbie invloved in crypto-world with few experenice. 
Futhermore, We'd like to get you contribution and bugfixing while going through this guild.  

## Content for setting up a node
1.  [Create a VPS on vultr](#Create-a-VPS-on-vultr)
2.  [Create a wallet account on Near guildnet](#Create-a-wallet-account-on-Near-guildnet)
3.  [Install Near-Shell](#Install-Near-Shell)
4.  [Setting up your environment](#Setting-up-your-environment)
5.  [Login through main wallet](#Login-through-main-wallet)
6.  [Install Nearup](#Install-Nearup)
7.  [Launch validator node](#Launch-validator-node)
8.  [Create staking pool](#Create-staking-pool)
9.  [Deploy contract](#Deploy-contract)
10. [Delegate tokens and get rewards](#Delegate-tokens-and-get-rewards)  
11. [Monitor validator node status](#Monitor-validator-node-status)


## Create a VPS on vultr
To become a validator, your validator node need to be create on VPS or your own machine. We recommand to create a VPS on vultr.com, which is easy to deploy & manage VPS and cost less. The minimum requirements of VPS is:
```bash
At least 2 CPUs
At least 4GB RAM
At least 100 GB free disk
```
You can create a account on [vultr.com](https://www.vultr.com/?ref=8661389)     
<img src="https://github.com/aquariusluo/images/blob/master/gn-vultr-create.png" width="500">   

Then deploy a new VPS on anywhere you prefer.  
<img src="https://github.com/aquariusluo/images/blob/master/gn-vultr-deploy.png" width="500">  

You can see VPS details like this. and record your public IP and password.
<img src="https://github.com/aquariusluo/images/blob/master/gn-vultr-vps-detail.png" width="500">  

## Create a wallet account on Near guildnet
You need a wallet account to hold your tokens operations, such as deposition, staking and withdrwa etc.  
To create a [guildnet wallet](https://wallet.openshards.io) and record your wallet address and seed phrase (12 words)  
_Tip: You may request 50,000 faucet from Near team for staking test._  

## Install Near-Shell
NEAR CLI is a Node.js application that relies on near-api-js to generate secure keys, connect to the NEAR platform and send transactions to the network on your behalf.  
_note that Node.js version 10+ is required to run NEAR CLI_   
Near-Shell doesn't need to be installed on the same machine as the validator, which is recommend to installed on a separate machine for increased security and performance. However it still can be installed on the same machine.
### Ubuntu Prerequisite Installation
```bash
sudo apt install python3 git curl clang build-essential
```
#### Install Node Version 12.x and npm
Nodes.js and npm can be install by
```bash
sudo apt install nodejs
sudo apt install npm
sudo n stable
PATH="$PATH"
```
#### Check Node.js and npm version  
```bash
node -v
v12.18.3
npm -v
6.14.6
```
### Install near-cli
```bash
git clone https://github.com/near-guildnet/near-cli.git
cd near-cli
# sudo may be needed.
npm install -g
```
## Setting up your environment
To use the guildnet network you need to update the environment via the command line.  
Open a command prompt and run
```bash
export NODE_ENV=guildnet
```
Add (export NODE_ENV=guildnet) to the end of the ~/.bashrc file to ensure it persists system restarts.
```bash
echo 'export NODE_ENV=guildnet' >> ~/.bashrc 
```

## Login through main wallet
To autherize Near-cil access to main wallet. we run at a command prompt to install ubuntu destop. Select [X]ubuntu destop option. 
```base
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install tasksel -y
sudo tasksel
```
Open remote desktop and execute command
```bash
near login
```
Subsequently, the browser will be opened and you need to restore main wallet account via Seed Phases. This action will autherize Near-cil access to main account.  
```
We prompt to use staketest.guildnet as main account ID, pool.staketest.guildnet as pool ID below.
```
Now, You can manage your main wallet account and smart contract by Near shell command. 
```bash
For account:
  near login                                       # logging in through NEAR protocol wallet
  near create-account <accountId>                  # create a developer account with --masterAccount (required), publicKey and initialBalance
  near state <accountId>                           # view account state
  near keys <accountId>                            # view account public keys
  near send <sender> <receiver> <amount>           # send tokens to given receiver
  near stake <accountId> <stakingKey> <amount>     # create staking transaction (stakingKey is base58 encoded)
  near delete <accountId> <beneficiaryId>          # delete an account and transfer funds to beneficiary account
  near delete-key [accessKey]                      # delete access key
  
For smart contract:
  near deploy [accountId] [wasmFile] [initFunction] [initArgs] [initGas] [initDeposit]  # deploy your smart contract
  near dev-deploy [wasmFile]                       # deploy your smart contract using temporary account (TestNet only)
  near call <contractName> <methodName> [args]     # schedule smart contract call which can modify state
  near view <contractName> <methodName> [args]     # make smart contract call which can view state
  near clean           
```
check your public key file of main account.
```bash
ls ~/.near-credentials/guildnet
staketest.guildnet.json
```
## Install Nearup
The Prerequisite has python3, git and curl toolset, which have been installed in previous step. please run command prompt.
```bash
curl --proto '=https' --tlsv1.2 -sSfL https://raw.githubusercontent.com/near-guildnet/nearup/master/nearup | python3
```
Nearup automatically adds itself to PATH: restart the terminal, or issue the command source ~/.profile. On each run, nearup self-updates to the latest version.  

## Launch validator node
We recommand to use Officially Compiled Binary to lauch validator node, which is suitable to run on VPS.  
Then, input your staking pool ID in the prompt by this command. 
```bash
nearup guildnet --nodocker
```
Check validator_key.json is generated for staking pool.
```bash
ls ~/.near/guildnet
validator_key.json  node_key.json  config.json  data  genesis.json
```
Check running status of validator node. If "V/" is showning up, your pool is selected in current validators list.
```bash
nearup logs -f
```

## Create staking pool
You need a staking pool account to benefit stakers or yourself. which can be generated by create_staking_pool command. following this prompt.
Check public key from ~/.near/guildnet/validator_key.json
```bash
cat ~/.near/guildnet/validator_key.json | grep public_key
```
```bash
near call stake.guildnet create_staking_pool '{"staking_pool_id": "<Pool ID need to be generated>", "owner_id": "<Master Account ID>", "stake_public_key": "<public_key in validator_key.json>", "reward_fee_fraction": {"numerator": 10, "denominator": 100}}' --accountId="<Master Account ID>" --amount=30 --gas=300000000000000
example:
near call stake.guildnet create_staking_pool '{"staking_pool_id": "pool.staketest.guildnet", "owner_id": "staketest.guildnet", "stake_public_key": "ed25519:4x1LrkFvxnh8Aeh8NQc9cn15XuYAVHA2aN6WVhFfCdaE", "reward_fee_fraction": {"numerator": 10, "denominator": 100}}' --accountId="blaze.guildnet" --amount=30 --gas=300000000000000
```

## Deploy contract
### Pre-requisites
To develop Rust contracts you would need to:  
   * Install Rustup:
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```
   * Add wasm target to your toolchain: 
```bash
rustup target add wasm32-unknown-unknown
```
   * Pull Core contract from github and build the contract
```bash
git clone https://github.com/near/core-contracts.git
cd core-contracts/staking-pool/
./build.sh
```
### Deploy contract
```bash
near deploy --accountId=<validator pool ID> --wasmFile=core-contracts/staking-pool/res/staking_pool.wasm
near call <validator pool ID> new '{"owner_id": "<main account ID>", "stake_public_key": "<pubilc key of validator pool>", "reward_fee_fraction": {"numerator": 10, "denominator": 100}}' --account_id <main account ID>
example:
near deploy --accountId=pool.staketest.guildnet --wasmFile=core-contracts/staking-pool/res/staking_pool.wasm
near call pool.staketest.guildnet new '{"owner_id": "staketest.guildnet", "stake_public_key": "<pool.staketest.guildnet pubilc key>", "reward_fee_fraction": {"numerator": 10, "denominator": 100}}' --account_id staketest.guildnet
```

## Delegate tokens and get rewards
   * As a user, to deposit Near tokens
```bash
near call <validator pool ID> deposit '{}' --accountId <main account ID> --amount <amount of Near tokens>
near call <validator pool ID> stake '{"amount": "<YoctoNEAR amount>"}' --accountId  <main account ID>
example:
near call pool.staketest.guildnet deposit '{}' --accountId staketest.guildnet --amount 75000
near call pool.staketest.guildnet stake '{"amount": "75000000000000000000000000000"}' --accountId staketest.guildnet
```
  * To update current rewards:
```bash
near call <validator pool ID> ping '{}' --accountId <main account ID>
example:
near call pool.staketest.guildnet ping '{}' --accountId staketest.guildnet
```
## Monitor validator node status
To be a validator, you can execute Near-cli to monitor and manager validator pool by your main account.  
  * Check if your pool is in proposals at first.
```bash
Near proposals | grep pool.staketest.guildnet
```
  * Check if your pool is in current validators list.
```bash
Near validators current | grep pool.staketest.guildnet
```  
  * Check if your pool is in next validators list.
```bash
Near validators next | grep pool.staketest.guildnet
```    
  * Check validator seat price. if your staking Near tokens is not enough to get a seat. please participate in the following challenges to get more Near tokens.
```bash
near validators current | grep "seat price"
```  
