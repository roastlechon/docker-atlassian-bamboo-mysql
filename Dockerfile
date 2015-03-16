FROM phusion/baseimage:0.9.12

ENV HOME /root

RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

CMD ["/sbin/my_init"]

# Some Environment Variables
ENV DEBIAN_FRONTEND noninteractive

ENV DOWNLOAD_URL https://www.atlassian.com/software/bamboo/downloads/binary/atlassian-bamboo-5.7.2.tar.gz

ENV BAMBOO_HOME /var/atlassian/application-data/bamboo

ENV BAMBOO_INSTALL_DIR /opt/atlassian/bamboo

RUN apt-get update
RUN apt-get install -y wget git default-jre

RUN sudo /bin/sh -c 'echo JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:/jre/bin/java::") >> /etc/environment'
RUN sudo /bin/sh -c 'echo BAMBOO_HOME=${BAMBOO_HOME} >> /etc/environment'

RUN mkdir -p ${BAMBOO_INSTALL_DIR}
RUN mkdir -p ${BAMBOO_HOME}

RUN wget -P /tmp ${DOWNLOAD_URL}
RUN tar zxf /tmp/atlassian-bamboo-5.7.2.tar.gz -C /tmp
RUN mv /tmp/atlassian-bamboo-5.7.2/* ${BAMBOO_INSTALL_DIR}/

RUN wget -P /tmp http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.34.tar.gz
RUN tar zxf /tmp/mysql-connector-java-5.1.34.tar.gz -C /tmp
RUN mv /tmp/mysql-connector-java-5.1.34/mysql-connector-java-5.1.34-bin.jar ${BAMBOO_INSTALL_DIR}/lib/

RUN mkdir /etc/service/bamboo
ADD runit/bamboo.sh /etc/service/bamboo/run
RUN chmod +x /etc/service/bamboo/run

EXPOSE 8085

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*