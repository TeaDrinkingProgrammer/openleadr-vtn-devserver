#!/bin/sh
set -euo pipefail

# Detect OS for sed compatibility
if [ "$(uname)" = "Darwin" ]; then
  # macOS requires an extension argument
  SED_INPLACE="sed -i ''"
else
  # Linux and others just use -i
  SED_INPLACE="sed -i"
fi

update_env_var() {
  local key="$1"
  local value="$2"
  
  echo "Updating environment variable: $key"
  
  # Create file if it doesn't exist
  if [ ! -f .env ]; then
    echo "Creating new .env file"
    touch data/.env
  fi
  
  echo "Checking if $key exists in .env file..."
  if grep -q "^${key}=" data/.env; then
    echo "Found existing value for $key - replacing it"
    # For debugging, show the current value
    echo "Current line: $(grep "^${key}=" data/.env)"
    # Quote the value to handle special characters
    $SED_INPLACE "s|^${key}=.*|${key}=\"${value}\"|" data/.env
    echo "Updated to: ${key}=\"${value}\""
  else
    echo "$key not found - adding new entry"
    # Check if we need a newline
    if [ -s "data/.env" ] && [ -n "$(tail -c1 data/.env)" ]; then
      echo "Adding newline before new entry"
      printf '\n' >> data/.env
    fi
    # Quote the value to handle special characters
    printf '%s="%s"\n' "$key" "$value" >> data/.env
    echo "Added new entry: ${key}=\"${value}\""
  fi
  
  echo "Current .env file contents:"
  cat data/.env
  echo "-------------------"
}

# Create OAuth2 Client
echo "Creating OAuth2 client..."
curl -s -X POST http://hydra:4445/admin/clients \
  -H 'Content-Type: application/json' \
  -d '{
    "audience": ["http://localhost:3000"],
    "grant_types": ["client_credentials"],
    "token_endpoint_auth_method": "client_secret_basic"
  }' > data/client.txt

CLIENT_ID=$(jq -r '.client_id' data/client.txt)
CLIENT_SECRET=$(jq -r '.client_secret' data/client.txt)

# curl -s -X POST http://hydra:4444/oauth2/token \
#    -F "grant_type=client_credentials" \
#    -F "client_id=$CLIENT_ID" \
#    -F "client_secret=$CLIENT_SECRET" \
#    -F "audience=http://localhost:3000" > data/token.txt

# ACCESS_TOKEN=$(jq -r '.access_token' data/token.txt)
# Extract client credentials using jq
OAUTH_CLIENT_ID=$CLIENT_ID
OAUTH_CLIENT_SECRET=$CLIENT_SECRET

echo "Client ID: $OAUTH_CLIENT_ID"
echo "Client Secret: $OAUTH_CLIENT_SECRET"

update_env_var "OAUTH_CLIENT_ID" "$OAUTH_CLIENT_ID"
update_env_var "OAUTH_CLIENT_SECRET" "$OAUTH_CLIENT_SECRET"