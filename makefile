rm_all:
	docker rm -f `docker ps -q -a`

rmi_all:
	docker rmi -f `docker images -q`

rmi_untagged:
	docker rmi -f `docker images | grep '^<none>' | awk '{print $$3}'`

build_all: build_base build_dbdata build_appdata build_web build_db 

build_dbdata: 
	docker create \
	-v /dbdata \
	--name dbdata \
	cfriedline/base \
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

start_db: run_web

start_db: 
	docker rm db
	docker run --name db -d \
	--volumes-from dbdata \
	-v /Users/chris:/mnt/tmp \
	cfriedline/db:latest

start_web: 
	docker rm web
	docker run --name web -P -d \
	--link db:db \
	--volumes-from appdata \
	cfriedline/web:latest

restart: stop run

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
	dropdb pineapp && \
	dropuser pineapp && \
	createdb pineapp && \
	createuser pineapp && \
	pg_restore -d pineapp /dbdata/pineapp.backup"

shell_web:
	docker exec -it web /bin/bash

shell_db:
	docker exec -it db /bin/bash
	
