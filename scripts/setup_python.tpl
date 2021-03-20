#! /bin/bash
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