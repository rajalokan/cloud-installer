### Image Service

```
# Setup Database for Glance
mysql -u root -p${PASSWORD} -e "CREATE DATABASE glance;"
mysql -u root -p${PASSWORD} -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY 'rajalokan';"
mysql -u root -p${PASSWORD} -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY 'rajalokan';"
```

```
openstack user create --domain default --password rajalokan glance
openstack role add --project service --user glance admin
openstack service create --name glance --description "OpenStack Image" image
openstack endpoint create --region RegionOne public public http://${IP_ADDR}:9292
openstack endpoint create --region RegionOne public internal http://${IP_ADDR}:9292
openstack endpoint create --region RegionOne public admin http://${IP_ADDR}:9292
```

```
sudo apt-get install glance
```

```
sudo bash -c 'cat << EOF > /etc/glance/glance-api.conf
[database]
connection = mysql+pymysql://glance:rajalokan@localhost/glance

[keystone_authtoken]
auth_uri = http://${IP_ADDR}:5000
auth_url = http://${IP_ADDR}:35357
memcached_servers = ${IP_ADDR}:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = glance
password = ${PASSWORD}

[paste_deploy]
flavor = keystone

[glance_store]
stores = file,http
default_store = file
filesystem_store_datadir = /var/lib/glance/images/
EOF'
```

```
sudo bash -c 'cat << EOF > /etc/glance/glance-registry.conf
[database]
connection = mysql+pymysql://glance:rajalokan@localhost/glance

[keystone_authtoken]
auth_uri = http://${IP_ADDR}:5000
auth_url = http://${IP_ADDR}:35357
memcached_servers = ${IP_ADDR}:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = glance
password = ${PASSWORD}
EOF'
```
