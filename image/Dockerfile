FROM centos:7
MAINTAINER Jason Ish <ish@unx.ca>

RUN yum -y update && \
    yum -y install epel-release && \
    yum -y install \
    tar \
    python-pip \
    cronie \
    logrotate \
    rsyslog \
    python-simplejson

RUN pip install supervisor

# Add Suricata repository.
RUN yum -y localinstall http://codemonkey.net/files/rpm/suricata/el7/suricata-release-el-7-1.el7.noarch.rpm
RUN yum -y install suricata-2.0.11

# Install a known version of idstools.
RUN /usr/bin/pip install \
    https://github.com/jasonish/py-idstools/archive/0.5.1.zip

# Move the default Suricata configuration out of the way.
RUN mv /etc/suricata /etc/suricata.dist

COPY /etc/ /etc/
COPY /tools /tools

RUN mkdir -p /etc/suricata/rules && \
    idstools-rulecat @/dev/null \
    --rules-dir=/etc/suricata/rules \
    --yaml-fragment=/etc/suricata/rules/rules.yaml \
    --temp=/var/tmp \
    --merged=/etc/suricata/rules/merged.rules

# Some cleanup.
RUN yum --noplugins clean all && \
    rm -rf /var/log/* || true && \
    rm -rf /var/tmp/* && \
    rm -rf /tmp/*

ENTRYPOINT ["/tools/boot"]

RUN /usr/sbin/suricata -V
