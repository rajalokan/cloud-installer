### Docker


#### Install Docker

sudo apt remove docker docker-engine

sudo apt update
sudo apt install -y linux-image-extra-$(uname -r) linux-image-extra-virtual

sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
sudo apt -y autoremote

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo apt-key fingerprint 0EBFCD88

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

sudo apt-get update

sudo apt-get -y install docker-ce

sudo docker ps



================================================================================
sudo groupadd docker

sudo usermod -aG docker $USER
