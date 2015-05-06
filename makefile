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
	@docker rm db
	docker run --name db -d cfriedline/db

run_web: run_db
	@docker rm web
	docker run --name web -d cfriedline/web

stop_web:
	docker stop web