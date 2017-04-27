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
echo "Password is ${PASSWORD} and IP is ${IP_ADDR}"
```

sudo apt install software-properties-common
sudo add-apt-repository cloud-archive:mitaka
sudo apt update && sudo apt -y dist-upgrade
sudo apt install -y python-openstackclient

### MySQL

```
sudo apt install -y mariadb-server python-pymysql
```

```
# Configure your mysql installation
sudo bash -c 'cat << EOF > /etc/mysql/conf.d/openstack.cnf
[mysqld]
bind-address = 0.0.0.0

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
sudo apt install -y memcached python-memcache
sudo service memcached restart
```
