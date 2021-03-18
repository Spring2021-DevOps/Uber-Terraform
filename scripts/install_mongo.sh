#! /bin/bash
# USAGE: Refer this script in terraform for aws_instance of mongodb
# SYNTAX: user_data = "${file("install_mongo.sh")}" 

wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list
sudo apt-get update -y
sudo apt-get install -y mongodb-org
sudo systemctl start mongod
sudo sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf
sudo systemctl restart mongod
