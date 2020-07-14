# SETUP A GuildNet NODE

sudo apt install python3 git curl
sudo ln -s /usr/bin/python3 /usr/bin/python
sudo apt install clang
sudo apt install build-essential
sudo apt install httpie
sudo apt install unzip

git clone https://github.com/near-guildnet/nearcore.git
cd nearcore
git checkout post-phase-1

mkdir ~/.near

SCP guildnet.zip to remove server
scp -i ~/.ssh/<yourkey_rsa> <dir>/guildnet.zip <user>@<ip>:<home dir>/.near/guildnet.zip

copy genesis.json and config.json node_key.json validator_key.json up

Create key for Node
near generate-key node.guildnet --nodeUrl=http://161.35.229.231:3030 --helperAccount guildnet --networkId guildnet

Update ~/.near/node_key.json 
1. cat ~/.near-credentials/guildnet/node.guildnet.json
2. Leave account_id blank
3. Update public_key
4. Update secret_key

Create key for Validator Account
near generate-key <account name>.guildnet --nodeUrl=http://161.35.229.231:3030 --helperAccount guildnet --networkId guildnet
http post http://164.90.144.140:3000/account newAccountId=<your account name>.guildnet newAccountPublicKey=<your generated public key>

Check account was created (you may get a timeout error)
near state <account name>.guildnet --nodeUrl=http://161.35.229.231:3030/ --networkId guildnet --helperAccount guildnet --masterAccount guildnet

Update ~/.near/validator_key.json
1. cat ~/.near-credentials/guildnet/<account name>.guildnet.json
2. Update account_id
3. Update public_key
4. Update secret_key

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env

./scripts/start_guildnet.py --nodocker --verbose