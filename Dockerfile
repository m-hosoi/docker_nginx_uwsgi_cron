FROM centos
MAINTAINER Masatsugu Hosoi<public.hosoi@gmail.com>

RUN yum -y install wget passwd cronie logrotate openssh-server
RUN yum -y install gcc python python-devel python-setuptools

# install nginx
ADD etc/nginx.repo /etc/yum.repos.d/nginx.repo
RUN yum -y install nginx


RUN yum -y install pyOpenSSL MySQL-python m2crypto

RUN easy_install pip
RUN pip install supervisor==3.1.3
ADD etc/python_modules.txt /tmp/python_modules.txt
RUN pip install -r /tmp/python_modules.txt

ADD etc/uwsgi.ini /etc/uwsgi.ini
ADD etc/uwsgi_params /etc/nginx/uwsgi_params
ADD etc/supervisord.conf /etc/supervisord.conf
ADD etc/nginx.conf /etc/nginx/nginx.conf
ADD etc/pam_crond /etc/pam.d/crond
RUN mkdir -p /srv/dev/

# ADD etc/cronjob /etc/cron.d/app
# RUN chmod 644 /etc/cron.d/app
# ADD app /srv/dev/server


EXPOSE 80 22
CMD ["/usr/bin/supervisord"]
