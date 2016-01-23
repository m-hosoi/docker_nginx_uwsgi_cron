FROM centos:7
MAINTAINER Masatsugu Hosoi<public.hosoi@gmail.com>

# install nginx
ADD etc/nginx.repo /etc/yum.repos.d/nginx.repo
ADD etc/python_modules.txt /tmp/python_modules.txt

RUN yum -y swap -- remove systemd-container systemd-container-libs -- install systemd systemd-libs

RUN yum -y install wget passwd cronie logrotate \
openssh-server gcc python python-devel \
python-setuptools nginx pyOpenSSL MySQL-python m2crypto zlib-devel \
libmemcached-devel libmemcached python-crypto
RUN easy_install pip \
&& pip install supervisor==3.1.3 && pip install -r /tmp/python_modules.txt
RUN mkdir -p /srv/dev/
RUN yum remove -y gcc cpp glibc-devel glibc-headers kernel-headers python-devel
RUN rm -rf /var/cache/*
RUN mkdir -p /var/cache/nginx
RUN localedef --list-archive | grep -v -e ^ja -e ^en_GB -e en_US -e ^zh | xargs localedef --delete-from-archive
RUN cp -a /usr/lib/locale/locale-archive /usr/lib/locale/locale-archive.tmpl
RUN build-locale-archive
RUN mkdir /tmp/locale
RUN cp -R /usr/share/locale/en /usr/share/locale/en_US /tmp/locale
RUN rm -rf /usr/share/locale/*
RUN mv /tmp/locale/* /usr/share/locale/
RUN rmdir /tmp/locale
RUN find /usr/lib/python2.7/site-packages/django/contrib/ -name 'LC_MESSAGES' | grep -v '/en/' | xargs rm -rf && find /usr/lib/python2.7/site-packages/django/conf/locale/ -name 'LC_MESSAGES' | grep -v '/en/' | xargs rm -rf && rm -rf /root/.cache

ADD etc/uwsgi.ini etc/supervisord.conf /etc/
ADD etc/uwsgi_params etc/nginx.conf /etc/nginx/
ADD etc/pam_crond /etc/pam.d/crond

# ADD etc/cronjob /etc/cron.d/app
# RUN chmod 644 /etc/cron.d/app
# ADD app /srv/dev/server


EXPOSE 80 22
CMD ["/usr/bin/supervisord"]
