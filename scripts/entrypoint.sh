#!/bin/sh

set -e 

python manage.py collectstatic --noinput


# setup to run our django

# database migration (provided by django)
# any change to orm, create migrations files
python manage.py wait_for_db
python manage.py migrate 

# 4 workers in a docker container
# if you have issue with the performance, can change it 1 worker 1 container.
#
# app.wsgi is the actual application our uwsgi going to run.
uwsgi --socket :9000 --workers 4 --master --enable-threads --module app.wsgi