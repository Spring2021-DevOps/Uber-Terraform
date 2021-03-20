#! /bin/bash
mkdir /home/ubuntu/webapp
cd /home/ubuntu/webapp
git clone https://"${git_username}":"${git_password}"@github.com/Spring2021-DevOps/Uber-Python.git
sudo apt update
sudo apt-get install python3
sudo apt install python3-pip
sudo apt install gunicorn
sudo apt-get install python3-venv
python3 -m venv env
source env/bin/activate
pip3 install -r requirements.txt
gunicorn -w 4 -b 0.0.0.0:5000 bookings:app