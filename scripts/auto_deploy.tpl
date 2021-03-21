#! /bin/bash

sudo apt-get update -y
sudo apt install npm -y
curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
sudo apt install nodejs -y
sudo apt install nginx -y
mkdir /home/ubuntu/app
echo db_host="${db_host}" >> /home/ubuntu/webapp.properties
cd /home/ubuntu/app
git init
git clone https://"${git_username}":"${git_password}"@github.com/Spring2021-DevOps/Uber-React.git
cd /home/ubuntu/app/Uber-React
sudo npm update
cd /home/ubuntu/app/Uber-React
sudo npm install
cd /home/ubuntu/app/Uber-React
sudo npm run build
cd ~
sudo rm /etc/nginx/sites-enabled/default

cat <<EOT >> /etc/nginx/sites-available/twtr.nginx
server {
  listen 80;
  listen [::]:80;
  root /home/ubuntu/app/Uber-React/build;
  index index.html;
  try_files \$uri \$uri/ /index.html;
  access_log /var/log/nginx/reverse-access.log; 
  error_log /var/log/nginx/reverse-error.log; 

  location /{
	try_files \$uri \$uri/ =404;
	add_header Cache-Control "no-cache"; 
  }
  location /static {
	 expires 1y;
	 add_header cache-Control "public";
  }

  location /api {
	 include proxy_params;
	 proxy_pass http://0.0.0.0:5000; 
  }

  client_max_body_size 20M; 
  proxy_connect_timeout 600s; 
  proxy_read_timeout 600s;
}
EOT

sudo ln -s /etc/nginx/sites-available/twtr.nginx /etc/nginx/sites-enabled/twtr.nginx
sudo systemctl reload nginx
echo "React Installation Complete" >> /home/ubuntu/status.txt

mkdir /home/ubuntu/webapp
cd /home/ubuntu/webapp
git clone https://"${git_username}":"${git_password}"@github.com/Spring2021-DevOps/Uber-Python.git
touch /home/ubuntu/updates.txt
sudo apt update
echo "apt update completed" >> /home/ubuntu/updates.txt
sudo apt-get install python3
echo "python3 installed" >> /home/ubuntu/updates.txt
sudo apt install python3-pip -y
echo "python3-pip installed" >> /home/ubuntu/updates.txt
sudo apt install gunicorn -y
echo "gunicorn installed" >> /home/ubuntu/updates.txt
sudo apt-get install python3-venv -y
echo "python3-venv installed" >> /home/ubuntu/updates.txt
cd /home/ubuntu/Uber-Python
sudo python3 -m venv /home/ubuntu/webapp/Uber-Python/env
echo "Virtual environment created" >> /home/ubuntu/updates.txt
source /home/ubuntu/webapp/Uber-Python/env/bin/activate && sudo pip3 install -r /home/ubuntu/webapp/Uber-Python/requirements.txt 
gunicorn -w 4 -b 0.0.0.0:5000 --chdir /home/ubuntu/webapp/Uber-Python uber:app
echo "Requirements installed" >> /home/ubuntu/updates.txt
echo "gunicorn started" >> /home/ubuntu/updates.txt