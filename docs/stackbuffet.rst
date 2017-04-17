### Stackbuffet


OPT_DIR=${OPT_DIR:-/opt}
echo ${OPT_DIR}

sudo chown -R ${USER}:${USER} /opt

git clone https://github.com/blueboxgroup/giftwrap.git ${OPT_DIR}/giftwrap

cd ${OPT_DIR}/giftwrap


docker build -t rajalokan/giftwrap .

docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v /vagrant/sample.yml:/tmp/manifest.yml  rajalokan/giftwrap
