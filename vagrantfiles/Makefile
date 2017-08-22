
build_trusty:
	./package.sh trusty

build_xenial:
	./package.sh xenial

build_centos:
	./package.sh centos

clean:
	cd "baseboxes" > /dev/null \
		&& vagrant status \
		&& vagrant destroy -f \
		&& vagrant status
	cd "playboxes" >/dev/null \
		&& vagrant status \
		&& vagrant destroy -f \
		&& vagrant status
