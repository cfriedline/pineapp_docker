init: build_all setup

rm_all:
	docker rm -f `docker ps -q -a`

rmi_all:
	docker rmi -f `docker images -q`

rmi_untagged:
	docker rmi -f `docker images | grep '^<none>' | awk '{print $$3}'`

build_all: build_data build_app build_admin

build_app: build_base build_web build_db 

build_data: build_anaconda build_appdata build_dbdata

build_dbdata: 
	docker create \
	-v /dbdata \
	--name dbdata \
	ubuntu:15.04 \
	/bin/bash

build_appdata:
	docker build \
	-t cfriedline/appdata \
	-f Dockerfile_appdata .
	docker create --name appdata cfriedline/appdata

build_base:
	docker build \
	-t cfriedline/base:latest \
	-f Dockerfile_base \
	.

build_web:
	docker build \
	-t cfriedline/web:latest \
	-f Dockerfile_web \
	.

build_db:
	docker build \
	-t cfriedline/db:latest \
	-f Dockerfile_db \
	.

build_admin:
	docker build \
	-t cfriedline/admin:latest \
	-f Dockerfile_admin \
	.

build_anaconda:
	docker build \
	-t cfriedline/anaconda:latest \
	-f Dockerfile_anaconda \
	.
	docker create --name anaconda cfriedline/anaconda

setup: start_db start_web init_django copy_db restore_db restart

start: start_db start_web

rm_names:
	docker rm web
	docker rm db

start_db: 
	./check_docker_container.sh db; \
	if [ $$? -eq 2 ]; \
	then docker rm db; \
	fi

	docker run --name db -d \
	--volumes-from dbdata \
	--volumes-from anaconda \
	-v /Users/chris:/mnt/tmp \
	cfriedline/db:latest

start_web: 
	./check_docker_container.sh web; \
	if [ $$? -eq 2 ]; \
	then docker rm web; \
	fi

	docker run --name web -P -d \
	--link db:db \
	--volumes-from appdata \
	--volumes-from anaconda \
	cfriedline/web:latest

start_admin:
	./check_docker_container.sh admin; \
	if [ $$? -eq 2 ]; \
	then docker rm admin; \
	fi

	docker run -it --name admin \
	--volumes-from appdata \
	--volumes-from dbdata \
	--volumes-from anaconda \
	--link web:web \
	--link db:db \
	cfriedline/admin \
	/bin/bash

restart: stop start

bounce_web: stop_web start_web


stop_web:
	docker stop web
	
stop_db:
	docker stop db
	
stop: stop_db stop_web

init_django:
	docker run -v /Users/chris/src:/mnt/src \
	--volumes-from appdata \
	cfriedline/web \
	cp -r /mnt/src/pineapp /appdata

copy_db:
	docker exec db \
	cp /mnt/tmp/science/pineapp.backup /dbdata

restore_db:
	docker exec \
	db \
	su - postgres -c "\
	createdb pineapp && \
	createuser pineapp && \
	pg_restore -d pineapp /dbdata/pineapp.backup"

shell_web:
	docker exec -it web /bin/bash

shell_db:
	docker exec -it db /bin/bash

wipe: stop rmi_all rm_all
	
