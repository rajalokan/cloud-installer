sudo yum -y upgrade
sudo yum install -y centos-release-openstack-ocata
sudo yum install -y openstack-selinux

sudo yum install -y cmake wget vim git

sudo yum install -y python-openstackclient

PASSWORD=rajalokan
IP_ADDR=$(hostname -I | cut -d" " -f2)
echo "Password is : ${PASSWORD} and IP is : ${IP_ADDR}"

sudo yum -y install mariadb mariadb-server python2-PyMySQL


sudo bash -c 'cat << EOF > /etc/my.cnf.d/openstack.cnf
[mysqld]
bind-address = 0.0.0.0

default-storage-engine = innodb
innodb_file_per_table = on
max_connections = 4096
collation-server = utf8_general_ci
character-set-server = utf8
EOF'

systemctl status mariadb.service
sudo systemctl enable mariadb.service
sudo systemctl start mariadb.service
systemctl status mariadb.service

mysql_secure_installation

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

=======================
MessageQ
======================
sudo yum install -y rabbitmq-server


systemctl status rabbitmq-server.service
sudo systemctl enable rabbitmq-server.service
sudo systemctl start rabbitmq-server.service
systemctl status rabbitmq-server.service

```
# Add a user to rabbitmq and setup permission
sudo rabbitmqctl add_user openstack ${PASSWORD}
sudo rabbitmqctl set_permissions openstack ".*" ".*" ".*"
# Verify Installation
sudo rabbitmqctl list_users
Listing users ...
guest   [administrator]
openstack       []
```


Memcached
=========
sudo yum install -y memcached python-memcached

systemctl status memcached.service
sudo systemctl enable memcached.service
sudo systemctl start memcached.service
systemctl status memcached.service


Keystone
=========

```
# Setup Database for Keystone
mysql -u root -p${PASSWORD} -e "CREATE DATABASE keystone;"
mysql -u root -p${PASSWORD} -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'rajalokan';"
mysql -u root -p${PASSWORD} -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'rajalokan';"
```

sudo yum install -y openstack-keystone httpd mod_wsgi

systemctl status httpd.service

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
mysql -u keystone -p${PASSWORD} keystone -e "SHOW TABLES;"

# Initialize Fernet key repositories:
sudo keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
sudo keystone-manage credential_setup --keystone-user keystone --keystone-group keystone

sudo keystone-manage bootstrap --bootstrap-password rajalokan --bootstrap-admin-url http://${IP_ADDR}:35357/v3/ --bootstrap-internal-url http://${IP_ADDR}:5000/v3/ --bootstrap-public-url http://${IP_ADDR}:5000/v3/ --bootstrap-region-id RegionOne


sudo ln -s /usr/share/keystone/wsgi-keystone.conf /etc/httpd/conf.d/

systemctl status httpd.service
sudo systemctl enable httpd.service
sudo systemctl start httpd.service
systemctl status httpd.service

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

source admin_openrc
openstack user list && openstack service list

```
openstack project create --domain default --description "Service Project" service
openstack project create --domain default --description "Demo Project" demo
openstack user create --domain default --password rajalokan demo
openstack role create user
openstack role add --project demo --user demo user
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


Glance
======

```
# Setup Database for Glance
mysql -u root -p${PASSWORD} -e "CREATE DATABASE glance;"
mysql -u root -p${PASSWORD} -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY 'rajalokan';"
mysql -u root -p${PASSWORD} -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY 'rajalokan';"
```


openstack user create --domain default --password rajalokan glance
openstack role add --project service --user glance admin
openstack service create --name glance --description "OpenStack Image" image
openstack endpoint create --region RegionOne image public http://${IP_ADDR}:9292
openstack endpoint create --region RegionOne image internal http://${IP_ADDR}:9292
openstack endpoint create --region RegionOne image admin http://${IP_ADDR}:9292


sudo yum install -y openstack-glance

```
# Use this galnce-api.conf instead
sudo bash -c 'cat << EOF > /etc/glance/glance-api.conf
[DEFAULT]

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
password = rajalokan

[paste_deploy]
flavor = keystone

[glance_store]
stores = file,http
default_store = file
filesystem_store_datadir = /var/lib/glance/images/

EOF'
```

```
# Use this galnce-registry.conf instead
sudo bash -c 'cat << EOF > /etc/glance/glance-registry.conf
[DEFAULT]

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
password = rajalokan

[paste_deploy]
flavor = keystone

EOF'
```

sudo su -s /bin/sh -c "glance-manage db_sync" glance

mysql -u glance -p${PASSWORD} glance -e "SHOW TABLES;"

systemctl status openstack-glance-api.service openstack-glance-registry.service
sudo systemctl enable openstack-glance-api.service openstack-glance-registry.service
sudo systemctl start openstack-glance-api.service openstack-glance-registry.service
systemctl status openstack-glance-api.service openstack-glance-registry.service


openstack image list
wget http://download.cirros-cloud.net/0.3.5/cirros-0.3.5-x86_64-disk.img -O /tmp/cirros.img

openstack image create "cirros" --file /tmp/cirros.img --disk-format qcow2 --container-format bare --public
openstack image list


NOVA
=====

```
# Setup Database for Nova
mysql -u root -p${PASSWORD} -e "CREATE DATABASE nova_api;"
mysql -u root -p${PASSWORD} -e "GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' IDENTIFIED BY 'rajalokan';"
mysql -u root -p${PASSWORD} -e "GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' IDENTIFIED BY 'rajalokan';"

mysql -u root -p${PASSWORD} -e "CREATE DATABASE nova;"
mysql -u root -p${PASSWORD} -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY 'rajalokan';"
mysql -u root -p${PASSWORD} -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY 'rajalokan';"

mysql -u root -p${PASSWORD} -e "CREATE DATABASE nova_cell0;"
mysql -u root -p${PASSWORD} -e "GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'localhost' IDENTIFIED BY 'rajalokan';"
mysql -u root -p${PASSWORD} -e "GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'%' IDENTIFIED BY 'rajalokan';"
```

openstack user create --domain default --password rajalokan nova
openstack role add --project service --user nova admin
openstack service create --name nova --description "OpenStack Compute" compute
openstack endpoint create --region RegionOne compute public http://${IP_ADDR}:8774/v2.1
openstack endpoint create --region RegionOne compute internal http://${IP_ADDR}:8774/v2.1
openstack endpoint create --region RegionOne compute admin http://${IP_ADDR}:8774/v2.1


openstack user create --domain default --password rajalokan placement
openstack role add --project service --user placement admin
openstack service create --name placement --description "Placement API" placement
openstack endpoint create --region RegionOne placement public http://${IP_ADDR}/placement
openstack endpoint create --region RegionOne placement internal http://${IP_ADDR}/placement
openstack endpoint create --region RegionOne placement admin http://${IP_ADDR}/placement

sudo yum install -y openstack-nova-api openstack-nova-conductor openstack-nova-console openstack-nova-novncproxy openstack-nova-scheduler openstack-nova-placement-api

```
# Use this nova.conf instead
sudo bash -c 'cat << EOF > /etc/nova/nova.conf
[DEFAULT]
enabled_apis = osapi_compute,metadata
transport_url = rabbit://openstack:rajalokan@localhost
my_ip = 192.168.2.221
use_neutron = True
firewall_driver = nova.virt.firewall.NoopFirewallDriver

[api_database]
connection = mysql+pymysql://nova:rajalokan@localhost/nova_api

[database]
connection = mysql+pymysql://nova:rajalokan@localhost/nova

[api]
auth_strategy = keystone

[keystone_authtoken]
auth_uri = http://192.168.2.221:5000
auth_url = http://192.168.2.221:35357
memcached_servers = 192.168.2.221:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = glance
password = rajalokan

[vnc]
enabled = true
vncserver_listen = $my_ip
vncserver_proxyclient_address = $my_ip

[glance]
api_servers = http://192.168.2.221:9292

[oslo_concurrency]
lock_path = /var/lib/nova/tmp

[placement]
os_region_name = RegionOne
project_domain_name = Default
project_name = service
auth_type = password
user_domain_name = Default
auth_url = http://192.168.2.221:35357/v3
username = placement
password = rajalokan

EOF'
```


sudo bash -c 'cat << EOF > /etc/httpd/conf.d/00-nova-placement-api.conf
<Directory /usr/bin>
    <IfVersion > = 2.4>
        Require all granted
    </IfVersion>
    <IfVersion < 2.4>
        Order allow,deny
        Allow from all
    </IfVersion>
</Directory>
EOF'

sudo su -s /bin/sh -c "nova-manage api_db sync" nova
mysql -u nova -p${PASSWORD} nova_api -e "SHOW TABLES;"


sudo su -s /bin/sh -c "nova-manage cell_v2 map_cell0" nova

sudo su -s /bin/sh -c "nova-manage cell_v2 create_cell --name=cell1 --verbose" nova

sudo su -s /bin/sh -c "nova-manage db sync" nova
mysql -u nova -p${PASSWORD} nova -e "SHOW TABLES;"


sudo nova-manage cell_v2 list_cells

systemctl status openstack-nova-api.service openstack-nova-consoleauth.service openstack-nova-scheduler.service openstack-nova-conductor.service openstack-nova-novncproxy.service
sudo systemctl enable openstack-nova-api.service openstack-nova-consoleauth.service openstack-nova-scheduler.service openstack-nova-conductor.service openstack-nova-novncproxy.service
sudo systemctl start openstack-nova-api.service openstack-nova-consoleauth.service openstack-nova-scheduler.service openstack-nova-conductor.service openstack-nova-novncproxy.service
systemctl status openstack-nova-api.service openstack-nova-consoleauth.service openstack-nova-scheduler.service openstack-nova-conductor.service openstack-nova-novncproxy.service


Compute Node
-------------

sudo yum install -y openstack-nova-compute

# Change in nova.conf


systemctl status libvirtd.service openstack-nova-compute.service
sudo systemctl enable libvirtd.service openstack-nova-compute.service
sudo systemctl start libvirtd.service openstack-nova-compute.service
systemctl status libvirtd.service openstack-nova-compute.service

egrep -c '(vmx|svm)' /proc/cpuinfo


openstack hypervisor list

# Discover compute nodes
sudo su -s /bin/sh -c "nova-manage cell_v2 discover_hosts --verbose" nova

openstack compute service list
openstack catalog list
openstack image list


Neutron
========

```
# Setup Database for Neutron
mysql -u root -p${PASSWORD} -e "CREATE DATABASE neutron;"
mysql -u root -p${PASSWORD} -e "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY 'rajalokan';"
mysql -u root -p${PASSWORD} -e "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY 'rajalokan';"
```


openstack user create --domain default --password rajalokan neutron
openstack role add --project service --user neutron admin
openstack service create --name neutron --description "OpenStack Networking" network
openstack endpoint create --region RegionOne network public http://${IP_ADDR}:9696
openstack endpoint create --region RegionOne network internal http://${IP_ADDR}:9696
openstack endpoint create --region RegionOne network admin http://${IP_ADDR}:9696

sudo yum install -y openstack-neutron openstack-neutron-ml2 openstack-neutron-linuxbridge ebtables

```
# Use this neutron.conf instead
sudo bash -c 'cat << EOF > /etc/neutron/neutron.conf
[DEFAULT]
core_plugin = ml2
service_plugins = router
allow_overlapping_ips = true
transport_url = rabbit://openstack:rajalokan@localhost
auth_strategy = keystone
notify_nova_on_port_status_changes = true
notify_nova_on_port_data_changes = true

[database]
connection = mysql+pymysql://neutron:rajalokan@localhost/neutron

[keystone_authtoken]
auth_uri = http://192.168.2.221:5000
auth_url = http://192.168.2.221:35357
memcached_servers = 192.168.2.221:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = neutron
password = rajalokan

[nova]
auth_url = http://192.168.2.221:35357
auth_type = password
project_domain_name = default
user_domain_name = default
region_name = RegionOne
project_name = service
username = nova
password = rajalokan

[oslo_concurrency]
lock_path = /var/lib/neutron/tmp

EOF'
```

sudo bash -c 'cat << EOF > /etc/neutron/plugins/ml2/ml2_conf.ini
[ml2]
type_drivers = flat,vlan,vxlan
tenant_network_types = vxlan
mechanism_drivers = linuxbridge,l2population
extension_drivers = port_security

[ml2_type_flat]
flat_networks = provider

[ml2_type_vxlan]
vni_ranges = 1:1000

[securitygroup]
enable_ipset = true

EOF'

sudo bash -c 'cat << EOF > /etc/neutron/plugins/ml2/linuxbridge_agent.ini
[linux_bridge]
physical_interface_mappings = provider:br-ex

[vxlan]
enable_vxlan = true
local_ip = 192.168.2.221
l2_population = true

[securitygroup]
enable_security_group = true
firewall_driver = neutron.agent.linux.iptables_firewall.IptablesFirewallDriver
EOF'

sudo bash -c 'cat << EOF > /etc/neutron/l3_agent.ini
[DEFAULT]
interface_driver = linuxbridge
EOF'

sudo bash -c 'cat << EOF > /etc/neutron/dhcp_agent.ini
[DEFAULT]
interface_driver = linuxbridge
dhcp_driver = neutron.agent.linux.dhcp.Dnsmasq
enable_isolated_metadata = true
EOF'

sudo bash -c 'cat << EOF > /etc/neutron/metadata_agent.ini
[DEFAULT]
nova_metadata_ip = 192.168.2.221
metadata_proxy_shared_secret = 1234567890
EOF'

[neutron]
url = http://192.168.2.221:9696
auth_url = http://192.168.2.221:35357
auth_type = password
project_domain_name = default
user_domain_name = default
region_name = RegionOne
project_name = service
username = neutron
password = rajalokan
service_metadata_proxy = true
metadata_proxy_shared_secret = 1234567890


sudo ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini

sudo su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron
mysql -u neutron -p${PASSWORD} neutron -e "SHOW TABLES;"

sudo systemctl restart openstack-nova-api.service

systemctl status neutron-server.service neutron-linuxbridge-agent.service neutron-dhcp-agent.service neutron-metadata-agent.service
sudo systemctl enable neutron-server.service neutron-linuxbridge-agent.service neutron-dhcp-agent.service neutron-metadata-agent.service
sudo systemctl start neutron-server.service neutron-linuxbridge-agent.service neutron-dhcp-agent.service neutron-metadata-agent.service
systemctl status neutron-server.service neutron-linuxbridge-agent.service neutron-dhcp-agent.service neutron-metadata-agent.service


systemctl status neutron-l3-agent.service
sudo systemctl enable neutron-l3-agent.service
sudo systemctl start neutron-l3-agent.service
systemctl status neutron-l3-agent.status
