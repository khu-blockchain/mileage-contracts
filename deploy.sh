#!/bin/bash

SCRIPT_NAME="SwMileageDeploy.s.sol"
DEPLOYMENTS_DIR="./artifacts"
OUTPUT_FILE="$DEPLOYMENTS_DIR/deploy.json"

forge script script/SwMileageDeploy.s.sol --broadcast

mkdir -p $DEPLOYMENTS_DIR

CONTRACTS_JSON=$([ -f "$OUTPUT_FILE" ] && cat $OUTPUT_FILE || echo "{}")

for CHAIN_DIR in broadcast/$SCRIPT_NAME/*/; do
  [ -d "$CHAIN_DIR" ] || continue
  CHAIN_ID=$(basename "$CHAIN_DIR")
  LATEST_RUN=$(ls -t $CHAIN_DIR/run-*.json 2>/dev/null | head -1)
  
  if [ -n "$LATEST_RUN" ]; then
    CONTRACTS=$(jq '.transactions | map(select(.transactionType == "CREATE")) | map({name: .contractName, address: .contractAddress}) | reduce .[] as $item ({}; . + {($item.name): $item.address})' $LATEST_RUN)
    CONTRACTS_JSON=$(echo $CONTRACTS_JSON | jq --arg chain "$CHAIN_ID" --argjson contracts "$CONTRACTS" '. + {($chain): {"contracts": $contracts}}')
  fi
done

echo $CONTRACTS_JSON | jq '.' > $OUTPUT_FILE
echo "Deployment artifacts saved to $OUTPUT_FILE"
