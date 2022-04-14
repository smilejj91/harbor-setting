# Quick start to install harbor

1. habor download and setting
 - modify harbor.yml (if you neeed)
   - hostname
   - port
   - certificate/prviate_key
   - harbor_admin_password
   - database.password
   - data_volume
 - modify setting.sh (if you neeed)
   - certficates configuration
 - $ ./setting.sh

2. start container 
 - $ cd harbor && docker-compose up -d

