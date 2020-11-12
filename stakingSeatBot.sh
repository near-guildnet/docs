#!/bin/bash
PATH="/usr/local/bin:/usr/bin:/bin"
PATH=$PATH
DEBUG_ALL=0
DEBUG_MIN=1

NETWORK="guildnet"
GUILDNET_EPOCH_LEN=5000
BETANET_EPOCH_LEN=10000
TESTNET=43200
MAINET=43200

export NODE_ENV=$NETWORK
export NODE_PATH=/usr/local/lib/node_modules/

HOST="https://rpc.openshards.io"
POOL_ID="node0.guildnet"
ACCOUNT_ID="node0.guildnet"
PUBLIC_KEY="ed25519:FKLR9zWTFZ7yazX74h4AqgmxDDhgr1cmaSky999keGsV"
SEAT_PRICE_BUFFER=100
NUM_SEATS_TO_OCCUPY=23

PARAMS='{"jsonrpc": "2.0", "method": "validators", "id": "dontcare", "params": [null]}'
CT='Content-Type: application/json'

COMMA=","
DOUBLE_QUOTE="\""

echo "Starting Script"
echo "---------------"

VALIDATORS=`curl -s -d "$PARAMS" -H "$CT" "$HOST"`
if [ "$DEBUG_ALL" == "1" ]
then
  echo "Validators: $VALIDATORS"
fi

STATUS=`curl -s "$HOST"`
if [ "$DEBUG_ALL" == "1" ]
then
  echo "STATUS: $STATUS"
fi

EPOCH_START=`echo $VALIDATORS | jq .result.epoch_start_height`
if [ "$DEBUG_MIN" == "1" ]
then
  echo "Epoch start: $EPOCH_START"
fi

LAST_BLOCK=`echo $STATUS | jq .sync_info.latest_block_height`
if [ "$DEBUG_MIN" == "1" ]
then
  echo "Last Block: $LAST_BLOCK"
fi

CURRENT_STAKE_S=`echo $VALIDATORS | jq -c ".result.current_validators[] | select(.account_id | contains (\"$POOL_ID\"))" | jq .stake`
CURRENT_STAKE_L=(${CURRENT_STAKE_S//\"/})
CURRENT_STAKE="${CURRENT_STAKE_L:0:6}"

if [ "$DEBUG_MIN" == "1" ]
then
  echo "Current Stake: $CURRENT_STAKE"
fi

VALIDATOR_NEXT_STAKE_S=`echo $VALIDATORS | jq -c ".result.next_validators[] | select(.account_id | contains (\"$POOL_ID\"))" | jq .stake`
VALIDATOR_NEXT_STAKE_L=(${VALIDATOR_NEXT_STAKE_S//\"/})
VALIDATOR_NEXT_STAKE="${VALIDATOR_NEXT_STAKE_L:0:6}"
if [ -z $VALIDATOR_NEXT_STAKE ]
then
  echo "$POOL_ID has been kicked"
fi

KICK_REASON=`echo $VALIDATORS | jq -c ".result.prev_epoch_kickout[] | select(.account_id | contains (\"$POOL_ID\"))" | jq .reason`

PROPOSAL_STAKE_S=`echo $VALIDATORS | jq -c ".result.current_proposals[] | select(.account_id | contains (\"$POOL_ID\"))" | jq .stake`
PROPOSAL_STAKE_L=(${PROPOSAL_STAKE_S//\"/})
PROPOSAL_STAKE="${PROPOSAL_STAKE_L:0:6}"
echo "Proposal Stake $PROPOSAL_STAKE"

#echo $VALIDATORS | jq -c ".result.current_proposals[]"
PROPOSAL_REASON=`echo $VALIDATORS | jq -c ".result.current_proposals[] | select(.account_id | contains (\"$POOL_ID\"))" | jq .reason`
echo "Proposal Reason: $PROPOSAL_REASON"

if [ -z $PROPOSAL_STAKE ]
then
  echo "Pool $POOL_ID does not have an active proposal"
else
  echo "Proposal Stake: $PROPOSAL_STAKE"
fi

if [[ -z "$VALIDATOR_NEXT_STAKE" || ! -z "$KICK_REASON" ]]
then
  if [ -z "$PROPOSAL_STAKE" ]
  then
    # PING THE POOL
    if [ "$DEBUG_ALL" == "1" ]
    then
      PING_COMMAND="near call $POOL_ID ping \"{}\" --accountId $ACCOUNT_ID"
      echo $PING_COMMAND
    fi
  fi
else
  echo "Validators Next Stake: $VALIDATOR_NEXT_STAKE"
fi

SEAT_PRICE=`near validators current | awk '/price/ {print substr($6, 1, length($6)-2)}'`
SEAT_PRICE="${SEAT_PRICE/$COMMA/}"
if [ "$DEBUG_MIN" == "1" ]
then
  echo "Seat Price: $SEAT_PRICE"
fi

SEAT_PRICE_NEXT=`near validators next | awk '/price/ {print substr($7, 1, length($7)-2)}'`
SEAT_PRICE_NEXT="${SEAT_PRICE_NEXT/$COMMA/}"
SEAT_PRICE_NEXT=$((SEAT_PRICE_NEXT * NUM_SEATS_TO_OCCUPY))
if [ "$DEBUG_MIN" == "1" ]
then
  echo "Seat Price Next: $SEAT_PRICE_NEXT"
fi

SEAT_PRICE_PROPOSALS=`near proposals | awk '/price =/ {print substr($15, 1, length($15)-1)}'`
SEAT_PRICE_PROPOSALS="${SEAT_PRICE_PROPOSALS/$COMMA/}"
SEAT_PRICE_PROPOSALS=$((SEAT_PRICE_PROPOSALS * NUM_SEATS_TO_OCCUPY))

if [ "$DEBUG_MIN" == "1" ]
then
  echo "Seat Price Proposals: $SEAT_PRICE_PROPOSALS"
fi

if [[ "$CURRENT_STAKE" -le "$SEAT_PRICE_NEXT" || "$CURRENT_STAKE" -le "$SEAT_PRICE_PROPOSALS" ]]
then
  echo "$CURRENT_STAKE is less than either $SEAT_PRICE_NEXT or $SEAT_PRICE_PROPOSALS"
  if [[ "$CURRENT_STAKE" -le "$SEAT_PRICE_NEXT" && "$PROPOSAL_STAKE" -le "$SEAT_PRICE_NEXT" ]]
  then
    echo "$SEAT_PRICE_NEXT  $CURRENT_STAKE $SEAT_PRICE_BUFFER"
    SEAT_PRICE_DIFF=$((SEAT_PRICE_NEXT - CURRENT_STAKE))
    echo "Seat Price Diff: $SEAT_PRICE_DIFF"
    echo "New Stake: $SEAT_PRICE_PROPOSALS"
    STAKE_CMD="near stake "$ACCOUNT_ID" "$PUBLIC_KEY" "${SEAT_PRICE_PROPOSALS}""
    echo "Stake CMD: $STAKE_CMD"
    STAKE=`$STAKE_CMD`
    echo "Stake updated $STAKE"

  elif [[ "$CURRENT_STAKE" -le "$SEAT_PRICE_PROPOSALS" && "$PROPOSAL_STAKE" -le "$SEAT_PRICE_PROPOSALS" ]]
  then
    echo "$SEAT_PRICE_NEXT  $CURRENT_STAKE $SEAT_PRICE_BUFFER"
   SEAT_PRICE_DIFF=$((SEAT_PRICE_NEXT - CURRENT_STAKE))
    echo "Seat Price Diff: $SEAT_PRICE_DIFF"
    NEW_STAKE=$((CURRENT_STAKE + SEAT_PRICE_DIFF))
    echo "New Stake: $NEW_STAKE"
    NEW_STAKE_WITH_BUFFER=$((NEW_STAKE + SEAT_PRICE_BUFFER))
    echo "New Stake with Buffer: $NEW_STAKE_WITH_BUFFER"
    NEW_STAKE_FORMATTED=`printf "%d%024d\n", $NEW_STAKE_WITH_BUFFER`
    echo "New Stake Formatted: ${NEW_STAKE_FORMATTED:0:24}"
    STAKE_CMD="near stake "$ACCOUNT_ID" "$PUBLIC_KEY" "${SEAT_PRICE_PROPOSALS}""
    echo "Stake CMD: $STAKE_CMD"
    STAKE=`$STAKE_CMD`
    echo "Stake updated $STAKE"

  elif [[ "$CURRENT_STAKE" -le "$SEAT_PRICE_PROPOSALS" && "$PROPOSAL_STAKE" -le "$SEAT_PRICE_PROPOSALS" ]]
  then
    echo "$SEAT_PRICE_NEXT  $CURRENT_STAKE $SEAT_PRICE_BUFFER"
    SEAT_PRICE_DIFF=$((SEAT_PRICE_PROPOSALS - CURRENT_STAKE))
    echo "Seat Price Diff: $SEAT_PRICE_DIFF"
    NEW_STAKE=$((CURRENT_STAKE + SEAT_PRICE_DIFF))
    echo "New Stake: $NEW_STAKE"
    NEW_STAKE_WITH_BUFFER=$((NEW_STAKE + SEAT_PRICE_BUFFER))
    echo "New Stake with Buffer: $NEW_STAKE_WITH_BUFFER"
    NEW_STAKE_FORMATTED=`printf "%d%024d\n", $NEW_STAKE_WITH_BUFFER`
    echo "New Stake Formatted: ${NEW_STAKE_FORMATTED:0:24}"
    STAKE_CMD="near stake "$ACCOUNT_ID" "$PUBLIC_KEY" "${SEAT_PRICE_PROPOSALS}""
    echo "Stake CMD: $STAKE_CMD"
    STAKE=`$STAKE_CMD`
    echo "Stake updated $STAKE"

  fi
elif [[ "$CURRENT_STAKE" -gt "$SEAT_PRICE_PROPOSALS" && "$PROPOSAL_STAKE" -le "$SEAT_PRICE_PROPOSALS" ]]
then
  echo "$SEAT_PRICE_NEXT  $CURRENT_STAKE $SEAT_PRICE_BUFFER"
  SEAT_PRICE_DIFF=$((CURRENT_STAKE - SEAT_PRICE_PROPOSALS))
  echo "Stake Diff: $SEAT_PRICE_DIFF"
  NEW_STAKE_WITH_BUFFER=$(((SEAT_PRICE_PROPOSALS - SEAT_PRICE_DIFF) + SEAT_PRICE_BUFFER))
  echo "New Stake with Buffer: $NEW_STAKE_WITH_BUFFER"
  NEW_STAKE_FORMATTED=`printf "%d%024d\n", $NEW_STAKE_WITH_BUFFER`
  echo "New Stake Formatted: ${NEW_STAKE_FORMATTED:0:24}"
  STAKE_CMD="near stake "$ACCOUNT_ID" "$PUBLIC_KEY" "${SEAT_PRICE_PROPOSALS}""
  echo "Stake CMD: $STAKE_CMD"
  STAKE=`$STAKE_CMD`
  echo "Stake updated $STAKE"
fi

echo "Script Done"
echo "----------- "
echo " "
