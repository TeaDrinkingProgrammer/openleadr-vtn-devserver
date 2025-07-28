#!/bin/sh
set -euo pipefail

# Create OAuth2 Client
echo "Creating OAuth2 client..."
curl -s -X POST http://hydra:4445/admin/clients \
  -H 'Content-Type: application/json' \
  -d '{
    "audience": ["http://localhost:3000"],
    "grant_types": ["client_credentials"],
    "token_endpoint_auth_method": "client_secret_post"
  }' > client.txt

# Extract client credentials using jq
CLIENT_ID=$(jq -r '.client_id' client.txt)
CLIENT_SECRET=$(jq -r '.client_secret' client.txt)

echo "Client ID: $CLIENT_ID"
echo "Client Secret: $CLIENT_SECRET"

# Generate Access Token
echo "Generating access token..."
curl -s -X POST http://hydra:4444/oauth2/token \
  -F "grant_type=client_credentials" \
  -F "client_id=$CLIENT_ID" \
  -F "client_secret=$CLIENT_SECRET" \
  -F "audience=http://localhost:3000" | jq -r '
    "ACCESS TOKEN\t" + .access_token + "\n" +
    "REFRESH TOKEN\t<empty>\n" +
    "ID TOKEN\t<empty>\n" +
    "EXPIRY\t\t" + (.expires_in | tostring) + " seconds"
  ' > token.txt

echo "Access token saved to token.txt"

# Extract Access Token
echo "Extracting access token..."
ACCESS_TOKEN=$(awk '/^ACCESS TOKEN/{print $3}' token.txt)
echo "Access Token: $ACCESS_TOKEN"

# Write the access token to the .env file
sed -i -e '/^ACCESS_TOKEN=/d' -e '$a\' .env 2>/dev/null || touch .env
echo "ACCESS_TOKEN=$ACCESS_TOKEN" >> .env 