
```
mysql -u root -p${PASSWORD} -e "CREATE DATABASE guts;"
mysql -u root -p${PASSWORD} -e "GRANT ALL PRIVILEGES ON guts.* TO 'guts'@'localhost' IDENTIFIED BY 'rajalokan';"
mysql -u root -p${PASSWORD} -e "GRANT ALL PRIVILEGES ON guts.* TO 'guts'@'%' IDENTIFIED BY 'rajalokan';"

unset `env | grep OS_ | cut -d'=' -f1 | xargs` && env | grep OS_
source admin_openrc
openstack user create --domain default --password rajalokan guts
openstack role add --project service --user guts admin
openstack service create --name guts --description "OpenStack Migration Service" migration
openstack endpoint create --region RegionOne migration public http://${IP_ADDR}:7000/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne migration internal http://${IP_ADDR}:7000/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne migration admin http://${IP_ADDR}:87000/v1/%\(tenant_id\)s
```

```
sudo apt-add-repository 'deb [arch=amd64] http://guts.stackbuffet.com/deb-test/ trusty-updates/mitaka main'
```


```
sudo bash -c 'cat << EOF > /etc/apt/preferences
Package: *
Pin: origin "180.148.27.143"
Pin-Priority: 999
EOF'
```

```
sudo bash -c 'cat << EOF > /etc/apt/apt.conf.d/98stackbuffet
APT::Get::AllowUnauthenticated "true";
EOF'
```

```
sudo apt-get update
```


```
sudo apt-get install -y guts-api
```


```
# Use this guts.conf instead
sudo bash -c 'cat << EOF > /etc/guts/guts.conf
[DEFAULT]
osapi_migration_workers = 2
rpc_backend = rabbit
debug = True
auth_strategy = keystone

[keystone_authtoken]
auth_uri = http://localhost:5000
auth_url = http://localhost:35357
memcached_servers = localhost:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = guts
password = rajalokan

[database]
connection = mysql+pymysql://guts:rajalokan@localhost/guts

[oslo_concurrency]
lock_path = /var/lib/guts

[oslo_messaging_rabbit]
rabbit_userid = openstack
rabbit_password = rajalokan
rabbit_host = 127.0.0.1
EOF'
```

```
sudo su -s /bin/sh -c "guts-manage db sync" guts
sudo service guts-api restart
```

```
guts list
guts source-list
guts service-list
```

```
sudo apt-get install -y guts-scheduler guts-migration
```

```
guts service-list
```

```
sudo apt-get install -y guts-dashboard
```

```
sudo bash -c 'cat << EOF >> /etc/openstack-dashboard/local_settings.py
OPENSTACK_API_VERSIONS = {
    "identity": 3
}
EOF'

sudo service apache2 restart
```
