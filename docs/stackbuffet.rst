### Stackbuffet


OPT_DIR=${OPT_DIR:-/opt}

sudo chown -R ${USER}:${USER} /opt

git clone https://dev.aptira.com/shunde/giftwrap.git ${OPT_DIR}/giftwrap

cd ${OPT_DIR}/giftwrap && docker build -t rajalokan/giftwrap .

mkdir -p /opt/repo /opt/giftwrap-manifests
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v /vagrant/sample.yml:/tmp/manifest.yml  rajalokan/giftwrap

docker run -v /opt/repo:/opt/repo -v /opt/giftwrap-manifests:/opt/giftwrap-manifests -it rajalokan/giftwrap bash

giftwrap build -t package -m /opt/giftwrap-manifests/guts/deb/guts_syslib.yml
