#!/bin/bash

# upgrade packages
sudo apt-get -y update -qq

sudo apt-get -qq update && \
     apt-get -qq -y --no-install-recommends install gnupg software-properties-common locales curl && \
     locale-gen en_US.UTF-8

sudo apt-get update && sudo apt-get install java-common -y -qq

# install openJDK
wget -O- https://apt.corretto.aws/corretto.key | sudo apt-key add - 
sudo add-apt-repository 'deb https://apt.corretto.aws stable main'
sudo apt-get update; sudo apt-get install -y java-11-amazon-corretto-jdk


# download and set permission for metabase
wget https://downloads.metabase.com/v0.38.0.1/metabase.jar
mkdir /opt/metabase/
mv metabase.jar /opt/metabase/metabase.jar
chmod 775 /opt/metabase/metabase.jar

# create service
printf '#!/bin/bash
java -jar /opt/metabase/metabase.jar' | tee -a /opt/metabase/metabase.sh
chmod +x /opt/metabase/metabase.sh
chmod 775 /opt/metabase/metabase.sh

printf '[Unit]
Description=Metabase

[Service]
ExecStart=/opt/metabase/metabase.sh
Restart=on-abnormal
WorkingDirectory=/opt/metabase/

[Install]
WantedBy=multi-user.target' | tee -a /etc/systemd/system/metabase.service

# activate service
systemctl enable metabase && systemctl start metabase

# open ports
ufw allow http
ufw allow https
ufw allow ssh
ufw allow 3000
