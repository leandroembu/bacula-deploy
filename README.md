# Bacula Deploy

Scripts to deploy bacula and bacula client (bacula-fd) on Debian 11.

- **bacula-director.sh:**
  - Compile and deploy all Bacula services
  - Deploy Baculum web client
- **bacula-client.sh**
  - Compile and deploy only bacula-fd service

## Requirements

- Debian 11 Bullseye
- For Ubuntu you must change pg_version variable (yes, it's hardcoded :( )

## TODO

[ ] Replace hardcoded Bacula version
[ ] Replace hardcoded PostgreSQL version
