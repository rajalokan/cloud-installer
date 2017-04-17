# OpenStack

## Ubuntu - 14.04

### Update & Upgrade

```
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
```

### General

```
# Chose a root password accordingly. We will use `rajalokan` as the root password.
PASSWORD=rajalokan
IP_ADDR=$(ifconfig eth0 | awk '/net addr/{print substr($2,6)}')
```

apt install software-properties-common
add-apt-repository cloud-archive:ocata
apt update && apt dist-upgrade
apt install python-openstackclient

### MySQL

```
apt install mariadb-server python-pymysql
```

```
# Configure your mysql installation
sudo bash -c 'cat << EOF > /etc/mysql/conf.d/openstack.cnf
[mysqld]
bind-address = 10.0.0.11

default-storage-engine = innodb
innodb_file_per_table = on
max_connections = 4096
collation-server = utf8_general_ci
character-set-server = utf8
EOF'
```

```
# Restart and setup secure installation
sudo service mysql restart
mysql_secure_installation
```

```
# Verify Mysql Installation
mysql -u root -p${PASSWORD} -e "SHOW DATABASES;"
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
+--------------------+
```

### Message Queue

```
# Install RabbitMQ
sudo apt-get install -y rabbitmq-server
# Add a user to rabbitmq and setup permission
sudo rabbitmqctl add_user openstack ${PASSWORD}
sudo rabbitmqctl set_permissions openstack ".*" ".*" ".*"
# Verify Installation
sudo rabbitmqctl list_users
Listing users ...
guest   [administrator]
openstack       []
```

### Memcached

```
sudo apt install memcached python-memcache
-l 10.0.0.11
sudo service memcached restart
```

### Identity Service

```
# Setup Database for Keystone
mysql -u root -p${PASSWORD} -e "CREATE DATABASE keystone;"
mysql -u root -p${PASSWORD} -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'rajalokan';"
mysql -u root -p${PASSWORD} -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'rajalokan';"
```

```
sudo apt-get install -y keystone
```

```
# Use this keysotne.conf instead
sudo bash -c 'cat << EOF > /etc/keystone/keystone.conf
[database]
connection = mysql+pymysql://keystone:rajalokan@localhost/keystone

[token]
provider = fernet
EOF'
```

sudo su -s /bin/sh -c "keystone-manage db_sync" keystone
# Initialize Fernet key repositories:
keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
keystone-manage credential_setup --keystone-user keystone --keystone-group keystone

```
# Bootstrap the identity service
keystone-manage bootstrap --bootstrap-password ADMIN_PASS \
  --bootstrap-admin-url http://controller:35357/v3/ \
  --bootstrap-internal-url http://controller:5000/v3/ \
  --bootstrap-public-url http://controller:5000/v3/ \
  --bootstrap-region-id RegionOne
```
