FROM centos:centos7
MAINTAINER Jason Ish <ish@unx.ca>

RUN yum -y update && \
    yum -y install epel-release && \
    yum -y install \
    tar \
    python-pip \
    cronie \
    logrotate \
    rsyslog

# Add Suricata repository.
RUN yum -y localinstall http://codemonkey.net/files/rpm/suricata/el7/suricata-release-el-7-1.el7.noarch.rpm
RUN yum -y install suricata

RUN /usr/bin/pip \
    install https://github.com/jasonish/py-idstools/archive/master.zip

# Move the default Suricata configuration out of the way.
RUN mv /etc/suricata /etc/suricata.dist

COPY /etc/ /etc/
COPY /tools /tools

# Some cleanup.
RUN yum --noplugins clean all && \
    rm -rf /var/log/* && \
    rm -rf /var/tmp/* && \
    rm -rf /tmp/*

ENTRYPOINT ["/tools/boot"]

RUN /usr/sbin/suricata -V
