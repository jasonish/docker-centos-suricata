FROM centos:centos7

MAINTAINER Jason Ish <ish@unx.ca>

# Add Suricata repository.
RUN yum -y localinstall http://codemonkey.net/files/rpm/suricata/el7/suricata-release-el-7-1.el7.noarch.rpm
RUN yum -y install suricata

RUN yum -y install \
    tar \
    python-pip \
    cronie \
    logrotate \
    rsyslog

RUN pip install supervisor
RUN pip install idstools

COPY etc/ /etc/
COPY /init.sh /
COPY /init.py /

RUN chmod 755 /init.py

# Some cleanup.
# RUN yum --noplugins clean all && \
#     rm -rf /var/log/* && \
#     rm -rf /tmp/*

ENTRYPOINT ["/init.py"]