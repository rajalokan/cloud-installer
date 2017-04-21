# Install horizon from source
sudo mkdir -p ${STACK_DIR} && sudo chown -R ${USER}:${USER} ${STACK_DIR}
git clone https://github.com/openstack/horizon ${STACK_DIR}/horizon
sudo -H pip install -e ${STACK_DIR}/horizon
rm -rf ${STACK_DIR}/horizon/openstack_dashboard/local/local_settings.py
cp ${STACK_DIR}/horizon/openstack_dashboard/local/local_settings.py.example ${STACK_DIR}/horizon/openstack_dashboard/local/local_settings.py
sudo bash -c 'cat << EOF >> /opt/stack/horizon/openstack_dashboard/local/local_settings.py
ALLOWED_HOSTS = ["*"]
OPENSTACK_API_VERSIONS = {
    "identity": 3
}
EOF'
cd ${STACK_DIR}/horizon && python manage.py runserver 0.0.0.0:8888


git clone https://dev.aptira.com/bharat/guts-dashboard.git ${STACK_DIR}/guts-dashboard
sudo -H pip install -e ${STACK_DIR}/guts-dashboard

ln -s ${STACK_DIR}/guts-dashboard/gutsdashboard/local/_50_guts.py ${STACK_DIR}/horizon/openstack_dashboard/local/enabled/_50_guts.py
ln -s ${STACK_DIR}/guts-dashboard/gutsdashboard/local/_5010_guts_services.py ${STACK_DIR}/horizon/openstack_dashboard/local/enabled/_5010_guts_services.py
ln -s ${STACK_DIR}/guts-dashboard/gutsdashboard/local/_5020_guts_resources.py ${STACK_DIR}/horizon/openstack_dashboard/local/enabled/_5020_guts_resources.py
ln -s ${STACK_DIR}/guts-dashboard/gutsdashboard/local/_5030_guts_migrations.py ${STACK_DIR}/horizon/openstack_dashboard/local/enabled/_5030_guts_migrations.py
