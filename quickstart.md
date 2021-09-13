# GuildNet Account Creation

## Wallet Creation
1. https://wallet.openshards.io


## Update your Node to GuildNet
1. Remove and Re-Install nearup (https://github.com/near-guildnet/nearup)
2. Remove and Re-Install near-shell (https://github.com/near-guildnet/near-shell)
3. Start your node: `nearup run guildnet`
4. Enter the wallet account created: `<account>.guildnet `
5. Post your account name `<account>.guildnet` in the tokens channel and request tokens
6. Get the public key from validators_key.json: `cat ~/.near/guildnet/validator_key.json`
7. Configure NEAR Shell for GuildNet: - `export NEAR_ENV=guildnet`
                                      - `echo 'export NODE_ENV=guildnet' >> ~/.bashrc`
9. Stake directly to your node: `near stake <account>.guildnet <staking public key> <amount to stake>`

**Need more detailed intructions see: [Setup a GuildNet Node](https://github.com/near-guildnet/docs/blob/master/new_node_setup.md)**
