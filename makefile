rm_all:
	docker rm -f `docker ps -q -a`

rmi_all:
	docker rmi -f `docker images -q`

build_all: build_base build_web build_db

build_base:
	docker build -t cfriedline/base:latest -f Dockerfile_base .

build_web:
	docker build -t cfriedline/web:latest \
	-f ../django-uwsgi-nginx/Dockerfile \
	../django-uwsgi-nginx

build_db:
	docker build -t cfriedline/db:latest -f Dockerfile_db .

run: run_web

run_db:
	docker stop db
	docker rm db
	docker run --name db -d cfriedline/db

run_web: run_db
	docker stop web
	docker rm web
	docker run --name web -p 8000 -d --link db:db cfriedline/web

stop_web:
	docker stop web