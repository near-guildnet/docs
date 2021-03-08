# Staking Pool Cheatsheet

- Any notes or instructions assume your using Ubuntu

This low-maintained cheatsheet supports Validators and Delegators who use [near-cli](https://github.com/near/near-cli) to manage their stake.

Replace `nearkat.stakingpool` with the name of your pool, and `pool_admin.nearkat` with the owner/administrator of the pool (or the account that is staking the tokens).

If you get stuck, give a look to the [troubleshooting page](https://github.com/nearprotocol/stakewars/blob/master/troubleshooting.md), open an issue, or join [near.chat](https://near.chat) on Discord


# Configure your Environment for guildnet

- REQUIRED: To send commands to the guildnet network 
```
echo "export NODE_ENV=guildnet" >> ~/.profile
source ~/.profile
```
- To switch networks mid-session
```
export NODE_ENV=testnet 
```


# Deploy a staking pool using the staking pool factory
- This uses the [staking pool factory](https://github.com/near/core-contracts/tree/master/staking-pool-factory) to deploy a staking pool. On the guildnet network you are free to deploy your own contracts if you choose. All pools deployed with this method on guildnet will end with the `.stake.guildnet` suffix.

- A staking pool contract is required for all validators. Please remember the staking pool contract controls all rewards, tracks delegations, and generally keeps track of everything.

- Call the staking pool factory `stake.guildnet` to deploy the contract
```
near call stake.guildnet create_staking_pool '{"staking_pool_id": "nearkat", "owner_id": "pool_admin.nearkat", "stake_public_key": "ed25519:00000000000000000000000000000000000000000042", "reward_fee_fraction": {"numerator": 10, "denominator": 100}}' --accountId="pool_admin.nearkat" --amount=30 --gas=300000000000000
```
From the example above, you have to replace:
- `nearkat` with the name of your staking pool (**HEADS UP:** the factory automatically adds its name to this parameter, creating `nearkat.stakingpool`)
- `pool_admin.nearkat` with the wallet that will control the staking pool
- `ed25519:0..042` with the public key in your `validator.json` file
- `25` with the fees that you like (in this case 25 over 100 is 25% of fees!)
- `pool_admin.nearkat` in the --accountId with your pool admin account
- be sure to have `30` NEAR available in your account (**HEADS UP:** keep the minimum balance to pay the [storage stake](https://near.org/papers/the-official-near-white-paper/#economics))

## Alternative: Deploying a custom staking pool using your locally-compiled contract
This method allows you to run your own fork of the [staking pool](https://github.com/near/core-contracts/tree/master/staking-pool).

- Deploy the smart contract in the account `my_cool_pool.nearkat`
(replace `my_cool_pool.nearkat` account with your cool pool name)
```
near deploy --accountId=my_cool_pool.nearkat --wasmFile=res/staking_pool_with_shares.wasm
```



# Configure your staking pool contract
(replace `my_cool_pool.nearkat`, `pool_admin.nearkat`, `stake_public_key` and `reward_fee_fraction` accordingly)
```
near call my_cool_pool.nearkat new '{"owner_id": "pool_admin.nearkat", "stake_public_key": "ed25519:00000000000000000000000000000000000000000042", "reward_fee_fraction": {"numerator": 25, "denominator": 100}}' --accountId pool_admin.nearkat
```
The pool above will have 25% of fees (25 numerator, 100 denominator).



# Manage your staking pool contract
- **HINT:** Copy/Paste everything after this line into a text editor and use search and replace

Once your pool is deployed, you can issue the commands below



## Owner Info
- Retrieve the owner ID of the staking pool
```
near view nearkat.stakingpool get_owner_id '{}'
```


## Staking Key and validator name
- Issue this command to retrieve the validators local name and public key
```
cat .near/guildnet/validator_key.json | grep "account_id\|public_key"
```
- Issue this command to retrieve the public key the network has for your validator
```
near view nearkat.stakingpool get_staking_key '{}'
```
- If the validator name does not match you will need to delete the guildnet folder and start over
- If the public key does not match you can update the staking key like this (replace the pubkey below with the key in your `validator.json` file)
```
near call nearkat.stakingpool update_staking_key '{"stake_public_key": "ed25519:00000000000000000000000000000000000000000042"}' --accountId pool_admin.nearkat
``` 



## Proposals
In order to get a validator seat you must first submit a proposal with an appropriate amount of stake. Proposals are sent for epoch +2. Meaning if you send a proposal now, if approved, you would get the seat in 3 epochs. You should submit a proposal every epoch to ensure your seat. To send a proposal we use the ping command. A proposal is also sent if a stake or unstake command is sent to the staking pool contract. 

- Ping the pool, paying gas from account `pool_admin.nearkat`
```
near call nearkat.stakingpool ping '{}' --accountId pool_admin.nearkat
```



## Transactions
- Deposit **10,000 NEAR** for the account `pool_admin.nearkat`. You should always deposit funds then issue a staking command.
```
near call nearkat.stakingpool deposit '' --accountId pool_admin.nearkat --amount 10000
```
- Stake **10,000 NEAR** (value in YoctoNEAR) with the account `pool_admin.nearkat`
```
near call nearkat.stakingpool stake '{"amount": "10000000000000000000000000000"}' --accountId pool_admin.nearkat
```
- Unstake **10,000 NEAR**(value in YoctoNEAR) from the account `pool_admin.nearkat`
```
near call nearkat.stakingpool unstake '{"amount": "10000000000000000000000000000"}' --accountId pool_admin.nearkat
```
- Withdraw **10,000 NEAR**s in YoctoNEAR from the account `pool_admin.nearkat`
```
near call nearkat.stakingpool withdraw '{"amount": "10000000000000000000000000000"}' --accountId pool_admin.nearkat
```



## Balances
- Retrieve the total balance in YoctoNEAR **for the account** `pool_admin.nearkat`
```
near view nearkat.stakingpool get_account_total_balance '{"account_id": "pool_admin.nearkat"}'
```
- Retrieve the staked balance in YoctoNEAR for the account `pool_admin.nearkat`
```
near view nearkat.stakingpool get_account_staked_balance '{"account_id": "pool_admin.nearkat"}'
```
- Retrieve the unstaked balance in YoctoNEAR for the account `pool_admin.nearkat`
```
near view nearkat.stakingpool get_account_unstaked_balance '{"account_id": "pool_admin.nearkat"}'
```
- Check if the unstaked balance for the account `pool_admin.nearkat` is unlocked. You can only withdraw funds from a contract if they are unlocked.
```
near view nearkat.stakingpool is_account_unstaked_balance_available '{"account_id": "pool_admin.nearkat"}'
```


### Pause / Resume Staking
- Pause
```
near call nearkat.stakingpool pause_staking '{}' --accountId pool_admin.nearkat
```
- Resume 
```
near call nearkat.stakingpool resume_staking '{}' --accountId pool_admin.nearkat
```
