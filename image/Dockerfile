FROM centos:centos7
MAINTAINER Jason Ish <ish@unx.ca>

RUN yum -y install epel-release && \
    yum -y install \
    tar \
    python-pip \
    cronie \
    logrotate \
    rsyslog

RUN /usr/bin/pip install supervisor
RUN /usr/bin/pip \
    install https://github.com/jasonish/py-idstools/archive/24807ad76c660178e1845784df4ae8230ac42d95/surirule.zip

# Add Suricata repository.
RUN yum -y localinstall http://codemonkey.net/files/rpm/suricata/el7/suricata-release-el-7-1.el7.noarch.rpm
RUN yum -y install suricata

# Move the default Suricata configuration out of the way.
RUN mv /etc/suricata /etc/suricata.dist

COPY /etc/ /etc/
COPY /init.py /
RUN chmod 755 /init.py

# Some cleanup.
RUN yum --noplugins clean all && \
    rm -rf /var/log/* && \
    rm -rf /var/tmp/* && \
    rm -rf /tmp/*

ENTRYPOINT ["/init.py"]