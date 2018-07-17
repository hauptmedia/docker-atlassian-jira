FROM		hauptmedia/java:oracle-java8
MAINTAINER	Julian Haupt <julian.haupt@hauptmedia.de>

ENV		JIRA_VERSION 7.11.0
ENV		MYSQL_CONNECTOR_J_VERSION 5.1.45

ENV		JIRA_HOME     /var/atlassian/application-data/jira
ENV		JIRA_INSTALL_DIR  /opt/atlassian/jira

ENV             RUN_USER            daemon
ENV             RUN_GROUP           daemon

ENV     	DEBIAN_FRONTEND noninteractive

# install needed debian packages & clean up
RUN		apt-get update && \
		apt-get install -y --no-install-recommends curl tar xmlstarlet ca-certificates ca-certificates-java && \
		apt-get clean autoclean && \
        	apt-get autoremove --yes && \
        	rm -rf /var/lib/{apt,dpkg,cache,log}/

# download and extract jira
RUN		mkdir -p ${JIRA_INSTALL_DIR} && \
		curl -L --silent https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-software-${JIRA_VERSION}.tar.gz | tar -xz --strip=1 -C ${JIRA_INSTALL_DIR} && \
		echo -e "\njira.home=$JIRA_HOME" >> "${JIRA_INSTALL_DIR}/atlassian-jira/WEB-INF/classes/jira-application.properties" && \
		chown -R ${RUN_USER}:${RUN_GROUP} ${JIRA_INSTALL_DIR}

# integrate mysql connector j library
RUN		curl -L --silent http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_CONNECTOR_J_VERSION}.tar.gz | tar -xz --strip=1 -C /tmp && \
		cp /tmp/mysql-connector-java-${MYSQL_CONNECTOR_J_VERSION}-bin.jar ${JIRA_INSTALL_DIR}/lib && \
		rm -rf /tmp/*

# Adding letsencrypt-ca to truststore
RUN    export KEYSTORE=$JAVA_HOME/jre/lib/security/cacerts && \
        wget -P /tmp/ https://letsencrypt.org/certs/letsencryptauthorityx1.der && \
        wget -P /tmp/ https://letsencrypt.org/certs/letsencryptauthorityx2.der && \
        wget -P /tmp/ https://letsencrypt.org/certs/lets-encrypt-x1-cross-signed.der && \
        wget -P /tmp/ https://letsencrypt.org/certs/lets-encrypt-x2-cross-signed.der && \
        wget -P /tmp/ https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.der && \
        wget -P /tmp/ https://letsencrypt.org/certs/lets-encrypt-x4-cross-signed.der && \
        keytool -trustcacerts -keystore $KEYSTORE -storepass changeit -noprompt -importcert -alias isrgrootx1 -file /tmp/letsencryptauthorityx1.der && \
        keytool -trustcacerts -keystore $KEYSTORE -storepass changeit -noprompt -importcert -alias isrgrootx2 -file /tmp/letsencryptauthorityx2.der && \
        keytool -trustcacerts -keystore $KEYSTORE -storepass changeit -noprompt -importcert -alias letsencryptauthorityx1 -file /tmp/lets-encrypt-x1-cross-signed.der && \
        keytool -trustcacerts -keystore $KEYSTORE -storepass changeit -noprompt -importcert -alias letsencryptauthorityx2 -file /tmp/lets-encrypt-x2-cross-signed.der && \
        keytool -trustcacerts -keystore $KEYSTORE -storepass changeit -noprompt -importcert -alias letsencryptauthorityx3 -file /tmp/lets-encrypt-x3-cross-signed.der && \
        keytool -trustcacerts -keystore $KEYSTORE -storepass changeit -noprompt -importcert -alias letsencryptauthorityx4 -file /tmp/lets-encrypt-x4-cross-signed.der

# add docker-entrypoint.sh script
COPY		docker-entrypoint.sh ${JIRA_INSTALL_DIR}/bin/ 

USER            ${RUN_USER}:${RUN_GROUP}

EXPOSE		8080

WORKDIR		${JIRA_INSTALL_DIR}
ENTRYPOINT	["bin/docker-entrypoint.sh"]
CMD		["bin/start-jira.sh", "-fg"]
