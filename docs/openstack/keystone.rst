### Identity Service

```
# Setup Database for Keystone
mysql -u root -p${PASSWORD} -e "CREATE DATABASE keystone;"
mysql -u root -p${PASSWORD} -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'rajalokan';"
mysql -u root -p${PASSWORD} -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'rajalokan';"
```

echo "manual" > /etc/init/keystone.override

```
sudo apt-get install -y keystone apache2 libapache2-mod-wsgi
```

```
# Use this keysotne.conf instead
sudo bash -c 'cat << EOF > /etc/keystone/keystone.conf
[DEFAULT]
admin_token = 1234567890

[database]
connection = mysql+pymysql://keystone:rajalokan@localhost/keystone

[token]
provider = fernet
EOF'
```

sudo su -s /bin/sh -c "keystone-manage db_sync" keystone

# Initialize Fernet key repositories:
keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone


```
sudo bash -c 'cat << EOF > /etc/apache2/sites-available/wsgi-keystone.conf
Listen 5000
Listen 35357

<VirtualHost *:5000>
    WSGIDaemonProcess keystone-public processes=5 threads=1 user=keystone group=keystone display-name=%{GROUP}
    WSGIProcessGroup keystone-public
    WSGIScriptAlias / /usr/bin/keystone-wsgi-public
    WSGIApplicationGroup %{GLOBAL}
    WSGIPassAuthorization On
    ErrorLogFormat "%{cu}t %M"
    ErrorLog /var/log/apache2/keystone.log
    CustomLog /var/log/apache2/keystone_access.log combined

    <Directory /usr/bin>
        Require all granted
    </Directory>
</VirtualHost>

<VirtualHost *:35357>
    WSGIDaemonProcess keystone-admin processes=5 threads=1 user=keystone group=keystone display-name=%{GROUP}
    WSGIProcessGroup keystone-admin
    WSGIScriptAlias / /usr/bin/keystone-wsgi-admin
    WSGIApplicationGroup %{GLOBAL}
    WSGIPassAuthorization On
    ErrorLogFormat "%{cu}t %M"
    ErrorLog /var/log/apache2/keystone.log
    CustomLog /var/log/apache2/keystone_access.log combined

    <Directory /usr/bin>
        Require all granted
    </Directory>
</VirtualHost>
EOF'
```

```
sudo ln -s /etc/apache2/sites-available/wsgi-keystone.conf /etc/apache2/sites-enabled
```

```
sudo service apache2 restart
```

```
sudo rm -f /var/lib/keystone/keystone.db
```

```
export OS_TOKEN=1234567890
export OS_URL=http://${IP_ADDR}:35357/v3
export OS_IDENTITY_API_VERSION=3
```

```
openstack user list
openstack service list
openstack service create --name keystone --description "OpenStack Identity" identity
openstack endpoint create --region RegionOne identity public http://${IP_ADDR}:5000/v3
openstack endpoint create --region RegionOne identity internal http://${IP_ADDR}:5000/v3
openstack endpoint create --region RegionOne identity admin http://${IP_ADDR}:35357/v3
openstack domain create --description "Default Domain" default
openstack project create --domain default --description "Admin Project" admin
openstack user create --domain default --password rajalokan admin
openstack role create admin
openstack role add --project admin --user admin admin
openstack project create --domain default --description "Service Project" service
openstack project create --domain default --description "Demo Project" demo
openstack user create --domain default --password rajalokan demo
openstack role create user
openstack role add --project demo --user demo user
```

```
unset OS_TOKEN OS_URL
```


```
# Generate admin openrc
cat > admin_openrc << EOF
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=rajalokan
export OS_AUTH_URL=http://${IP_ADDR}:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
EOF
```

```
source admin_openrc
openstack user list && openstack service list
```

```
# Generate demo openrc
cat > demo_openrc << EOF
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=demo
export OS_USERNAME=demo
export OS_PASSWORD=rajalokan
export OS_AUTH_URL=http://${IP_ADDR}:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
EOF
```


```
unset `env | grep OS_ | cut -d'=' -f1 | xargs` && env | grep OS_
```

keystone-manage credential_setup --keystone-user keystone --keystone-group keystone

```
# Bootstrap the identity service
keystone-manage bootstrap --bootstrap-password ADMIN_PASS \
  --bootstrap-admin-url http://controller:35357/v3/ \
  --bootstrap-internal-url http://controller:5000/v3/ \
  --bootstrap-public-url http://controller:5000/v3/ \
  --bootstrap-region-id RegionOne
```
