# SETUP A GuildNet NODE
This guide will help you setup a NEAR validator node on Guildnet. We provide step by step instructions to assist even those new to validating. 
We'd appreciate your contribution and feedback on this guild.  

## Content for setting up a node
1.  [Server Requirements](#Server-Requirements)
2.  [Create a wallet account on Near guildnet](#Create-a-wallet-account-on-Near-guildnet)
3.  [Install Near-Shell](#Install-Near-Cli)
4.  [Setting up your environment](#Setting-up-your-environment)
5.  [Login through main wallet](#Login-through-main-wallet)
6.  [Install Nearup](#Install-Nearup)
7.  [Launch validator node](#Launch-validator-node)
8.  [Create staking pool](#Create-staking-pool)
9. [Delegate tokens and get rewards](#Delegate-tokens-and-get-rewards)  
10. [Monitor validator node status](#Monitor-validator-node-status)


## Server Requirements
To become a validator your server will need to meet these minimum requirements:
```bash
At least 2-Core (4-Thread) Intel i7/Xeon equivalent
At least 16GB RAM
At least 100GB SSD (Note: HDD will not work)
```  
## Create a wallet account on Near guildnet
You will need a wallet.  
To create a [guildnet wallet](https://wallet.openshards.io) go to: [https://wallet.openshards.io](https://wallet.openshards.io) be sure to record your wallet address and seed phrase (12 words)  
_Tip: You may request 75,000 faucet from Near team for staking test._  

## Install Near-Cli
NEAR CLI is a Node.js application that relies on near-api-js to generate secure keys, connect to the NEAR platform and send transactions to the network on your behalf.  
_note that Node.js version 10+ is required to run NEAR CLI_   


**Near-Cli doesn't need to be installed on the same machine as the validator, which is recommend to installed on a separate machine for increased security and performance. However it still can be installed on the same machine.**

### Ubuntu Prerequisite Installation
```bash
sudo apt install python3 git curl clang build-essential
```
#### Install Node Version 12.x and npm
Nodes.js and npm can be install by
```bash
sudo apt install nodejs
sudo apt install npm
sudo npm install -g n
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
To authorize Near-Cli access we need to login via the command prompt.
```bash
near login
```
Subsequently, the browser will be opened, if it does not simply copy and paste the generated link into the browser. You may need to restore your wallet account via Seed Phase. This action will authorize Near-cli access to main account via the shell.  
```
We recommend using <your account>.guildnet as main accountId and <your pool>.stake.guildnet as pool ID below.
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
We recommand to use Officially Compiled Binary to launch a validator node, which is suitable to run on VPS.  
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
You need to setup a staking pool which can be generated by create_staking_pool command.
Check public key from ~/.near/guildnet/validator_key.json
```bash
cat ~/.near/guildnet/validator_key.json | grep public_key
```
```bash
near call stake.guildnet create_staking_pool '{"staking_pool_id": "<Pool ID need to be generated>", "owner_id": "<Master Account ID>", "stake_public_key": "<public_key in validator_key.json>", "reward_fee_fraction": {"numerator": 10, "denominator": 100}}' --accountId="<Master Account ID>" --amount=30 --gas=300000000000000
example:
near call stake.guildnet create_staking_pool '{"staking_pool_id": "testpool", "owner_id": "staketest.guildnet", "stake_public_key": "ed25519:4x1LrkFvxnh8Aeh8NQc9cn15XuYAVHA2aN6WVhFfCdaE", "reward_fee_fraction": {"numerator": 10, "denominator": 100}}' --accountId="blaze.guildnet" --amount=30 --gas=300000000000000
```
## Delegate tokens and get rewards
   * As a user, to deposit and stake Near tokens
```bash
near call <validator pool ID> deposit_and_stake --amount <amount of Near tokens> --accountId <main account ID>
example:
near call testpool.stake.guildnet deposit_and_stake --amount 70000 --accountId staketest.guildnet
```
  * To update current rewards:
```bash
near call <validator pool ID> ping '{}' --accountId <main account ID>
example:
near call testpool.stake.guildnet ping '{}' --accountId staketest.guildnet
```
## Monitor validator node status
To be a validator, you can execute Near-cli to monitor and manager validator pool by your main account.  
  * Check if your pool is in proposals at first.
```bash
Near proposals | grep testpool.stake.guildnet
```
  * Check if your pool is in current validators list.
```bash
Near validators current | grep testpool.stake.guildnet
```  
  * Check if your pool is in next validators list.
```bash
Near validators next | grep testpool.stake.guildnet
```    
  * Check validator seat price. if your staking Near tokens is not enough to get a seat. please participate in the following challenges to get more Near tokens.
```bash
near validators current | grep "seat price"
```  
