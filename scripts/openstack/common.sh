
function _preconfigure_installation {
sudo apt install software-properties-common
sudo add-apt-repository cloud-archive:mitaka
sudo apt update && sudo apt -y dist-upgrade
sudo -H pip install python-openstackclient

}
