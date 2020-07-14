# GuildNet Account Creation

## Wallet Creation
1. sudo apt install httpie
2. near generate-key <your account name>.guildnet --networkId guildnet --helperAccount guildnet
3. Copy public key and use with the next command
4. http post http://164.90.144.140:3000/account newAccountId=<your account name>.guildnet newAccountPublicKey=<your generated public key>


## Update your GuildNet node
2. cat ~/.near-credentials/guildnet/<your account name>.json
2. Update validator_key.json with your: Account Name, Public Key, and Private Key
3. Delete the data director rm -R ~/.near/data
4. Restart your node