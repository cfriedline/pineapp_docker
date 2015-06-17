##Prerequisites
* A working [Docker](www.docker.com) setup
* A backup of the `pineapp` database
* The source code (including settings.py) for the [Django](www.djangoproject.com) site
* Adjust the makefile setup targets, `init_django` and `copy_db` to reflect the above

##Build 

`make init` or `make`

You may also have to create /anaconda on your docker host, and chwon to the user running docker, if not root

##Run

`make start`

