# OpenLEADR VTN devserver

A docker setup that combines an OpenLEADR VTN with Hydra, and bootstraps a user with access token.
The access token is written to the `ACCESS_TOKEN` variable in the .env file.

**DO NOT USE IN PRODUCTION**

This setup is intended for testing and development purposes only. In production, use a separate OAUTH server or service and create a user with appropriate claims for each use-case.

## Getting an access token
1. Load .env with a program like direnv or prefix this:
```
OAUTH_CLIENT_ID=<client_id_from_env_here>
OAUTH_CLIENT_SECRET=<client_secret_from_env_here>
```

2. Request access token
```sh

curl -s -X POST http://localhost:4444/oauth2/token \
   -F "grant_type=client_credentials" \
   -F "client_id=$OAUTH_CLIENT_ID" \
   -F "client_secret=$OAUTH_CLIENT_SECRET" \
   -F "audience=http://localhost:3000" | jq -r '
     "ACCESS TOKEN\t" + .access_token + "\n" +
     "REFRESH TOKEN\t<empty>\n" +
     "ID TOKEN\t<empty>\n" +
     "EXPIRY\t\t" + (.expires_in | tostring) + " seconds"
   '
```