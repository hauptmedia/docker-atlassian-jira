FROM		hauptmedia/java:oracle-java8
MAINTAINER	Julian Haupt <julian.haupt@hauptmedia.de>

ENV		JIRA_VERSION 6.4.11
ENV		MYSQL_CONNECTOR_J_VERSION 5.1.34

ENV		JIRA_HOME     /var/atlassian/application-data/jira
ENV		JIRA_INSTALL_DIR  /opt/atlassian/jira

ENV             RUN_USER            daemon
ENV             RUN_GROUP           daemon

ENV     	DEBIAN_FRONTEND noninteractive

# install needed debian packages & clean up
RUN		apt-get update && \
		apt-get install -y --no-install-recommends curl tar xmlstarlet ca-certificates && \
		apt-get clean autoclean && \
        	apt-get autoremove --yes && \
        	rm -rf /var/lib/{apt,dpkg,cache,log}/

# download and extract jira
RUN		mkdir -p ${JIRA_INSTALL_DIR} && \
		curl -L --silent http://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-${JIRA_VERSION}.tar.gz | tar -xz --strip=1 -C ${JIRA_INSTALL_DIR} && \
		echo -e "\njira.home=$JIRA_HOME" >> "${JIRA_INSTALL_DIR}/atlassian-jira/WEB-INF/classes/jira-application.properties" && \
		chown -R ${RUN_USER}:${RUN_GROUP} ${JIRA_INSTALL_DIR}

# integrate mysql connector j library
RUN		curl -L --silent http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_CONNECTOR_J_VERSION}.tar.gz | tar -xz --strip=1 -C /tmp && \
		cp /tmp/mysql-connector-java-${MYSQL_CONNECTOR_J_VERSION}-bin.jar ${JIRA_INSTALL_DIR}/lib && \
		rm -rf /tmp/*

# add docker-entrypoint.sh script
COPY		docker-entrypoint.sh ${JIRA_INSTALL_DIR}/bin/ 

USER            ${RUN_USER}:${RUN_GROUP}

EXPOSE		8080

VOLUME		["${JIRA_INSTALL_DIR}"]

WORKDIR		${JIRA_INSTALL_DIR}
ENTRYPOINT	["bin/docker-entrypoint.sh"]
CMD		["bin/start-jira.sh", "-fg"]
