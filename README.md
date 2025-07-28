# OpenLEADR VTN devserver

A docker setup that combines an OpenLEADR VTN with Hydra, and bootstraps a user with access token.
The access token is written to the `ACCESS_TOKEN` variable in the .env file.

**DO NOT USE IN PRODUCTION**

This setup is intended for testing and development purposes only. In production, use a separate OAUTH server or service and create a user with appropriate claims for each use-case.