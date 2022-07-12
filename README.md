# Bacula Deploy

Scripts to deploy bacula and bacula client (bacula-fd) on Debian 11.

## TODO

- [ ] Replace hardcoded Bacula version
- [ ] Replace hardcoded PostgreSQL version

## Scripts

- **bacula-director.sh:**
  - Compile and deploy all Bacula services
  - Deploy Baculum web client
- **bacula-client.sh**
  - Compile and deploy only bacula-fd service

## Requirements

- Debian 11 Bullseye
- For Ubuntu you must change pg_version variable (yes, it's hardcoded :( )

## Bacula Server (Director + Client + Storage + Baculum)

After running _bacula-director.sh_, test your Bacula Console (the domain must be in /etc/hosts if you're using FQDN):

`# bconsole`

![bconsole](https://user-images.githubusercontent.com/3253741/178515741-c5092e66-1d6f-415c-a4b9-78aa5ca91a51.png)

### Access Baculum API Config

Access http://your-server:9096 and proceed with Baculum API configuration.
User: admin
Password: admin

![Baculum API Config](https://user-images.githubusercontent.com/3253741/178516340-4edf8597-ee03-425e-a778-6a6bc625ae87.png)

![Baculum API Config](https://user-images.githubusercontent.com/3253741/178516484-aba9fdcf-a16f-4192-ba0f-4a58c0e3e0d6.png)

![Baculum API Config](https://user-images.githubusercontent.com/3253741/178516856-ebc8800b-7c24-42a9-8e9a-2c524c764625.png)

Share the Bacula configuration interface

![Baculum API Config](https://user-images.githubusercontent.com/3253741/178517006-64421356-32cd-4ddc-aa3f-7761ccf4f523.png)

![Baculum API Config](https://user-images.githubusercontent.com/3253741/178517294-f5017f13-0a84-4d93-8fcc-945aa3e05d03.png)

Configure your authentication method

![Baculum API Config](https://user-images.githubusercontent.com/3253741/178517444-4adfc1c9-a75f-4768-9d7c-04725e86ef91.png)

![Baculum API up and running](https://user-images.githubusercontent.com/3253741/178517582-ca5b0cab-3f19-4033-9d90-4f3b46bbbbdb.png)

### Access Baculum

Access Baculum - http://your-server:9095 to config the API authentication.

![Baculum Config](https://user-images.githubusercontent.com/3253741/178518074-a1b6ff23-1256-4538-89d4-6fa6ad013e27.png)

Create user and password to Baculum Web Panel access

![Baculum Web Panel config](https://user-images.githubusercontent.com/3253741/178518232-bbfb7a17-d987-423a-b629-f15fa1e7b195.png)

![Baculum up and running](https://user-images.githubusercontent.com/3253741/178518333-3a82bcae-4b6b-46f9-929c-71a9ef4beb85.png)


Now configure passwords for bacula-dir, bacula-sd, etc.

## Bacula Client (only bacula-fd service)

After running _bacula-client.sh_, check bacula service status:

`# bacula status`

![Bacula FD service is running](https://user-images.githubusercontent.com/3253741/178519489-4e14e868-1d35-4a71-a4eb-605643ef6b01.png)
