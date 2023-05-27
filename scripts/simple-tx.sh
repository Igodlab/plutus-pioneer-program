#!/bin/bash

dirpath=$HOME/workspace/repo/keys/txs
keypath=$HOME/workspace/repo/keys
mkdir -p "$dirpath"

dateStamp="$(date -u +%F)"
from="$1"
to="$2"
value="$3"
txin="$4"

pp="$dirpath/protocol-parameters-$dateStamp.json"
body="$dirpath/simple-tx-$dateStamp.txbody"
tx="$dirpath/simple-tx-$dateStamp.tx"

# Query the protocol parameters \

cardano-cli query protocol-parameters \
    --testnet-magic 2 \
    --out-file "$pp"

# Build the transaction
cardano-cli transaction build \
    --babbage-era \
    --testnet-magic 2 \
    --tx-in "$txin" \
    --change-address "$(cat "$keypath/$from.addr")" \
    --tx-out "$(cat "$keypath/$to.addr")"+"$value" \
    --protocol-params-file "$pp" \
    --out-file "$body"
    
# Sign the transaction
cardano-cli transaction sign \
    --tx-body-file "$body" \
    --signing-key-file "$keypath/$from.skey" \
    --testnet-magic 2 \
    --out-file "$tx"

# Submit the transaction
cardano-cli transaction submit \
    --testnet-magic 2 \
    --tx-file "$tx"

tid=$(cardano-cli transaction txid --tx-file "$tx")
echo "transaction id: $tid"
echo "Cardanoscan: https://preview.cardanoscan.io/transaction/$tid"