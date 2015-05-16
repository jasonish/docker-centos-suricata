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
RUN yum -y install suricata

# Install the most recent rulecat from idstools.
# RUN /usr/bin/pip \
#     install https://github.com/jasonish/py-idstools/archive/master.zip

# Install a known version of idstools.
RUN /usr/bin/pip install \
https://github.com/jasonish/py-idstools/archive/ce60ebf6ecdcb676de69a05ae558948f2f69f8d6.zip

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
