
```
sudo yum install -y centos-release-openstack-mitaka
sudo yum install -y openstack-packstack
sudo packstack --gen-answer-file=/opt/packstack-answer-file
```

sudo packstack --answer-file ~/packstack-answer-file

```
openstack image list
wget http://download.cirros-cloud.net/0.3.5/cirros-0.3.5-x86_64-disk.img -O /tmp/cirros.img
openstack image create "cirros" --file /tmp/cirros.img --disk-format qcow2 --container-format bare --public
rm -rf /tmp/cirros.img
openstack image list
```

```
# Run some sample commands  & boot a vm
openstack user list
openstack keypair list
ssh-keygen -t rsa -f ~/.ssh/cloud.key -N ''
openstack keypair create --public-key ~/.ssh/cloud.key.pub cloud
openstack keypair list
```

```
openstack security group rule list default
openstack security group rule create --proto icmp default
openstack security group rule create --proto tcp --src-ip 0.0.0.0/0 --dst-port 22 default
openstack security group rule list default
```

```
openstack network list
openstack network create --share public
neutron subnet-create --allocation-pool start=192.168.167.151,end=192.168.167.200 --dns-nameserver '8.8.8.8' public 192.168.167.0/24
openstack network create --share private
neutron subnet-create private 10.0.0.0/24
openstack network list
```

```
openstack server create --image cirros --flavor m1.tiny --security-group default --key-name cloud --nic "net-id=$(openstack network show -f value -c id private)" trybox
openstack server list
openstack ip floating add $(openstack ip floating create -f value -c ip public) trybox
```
