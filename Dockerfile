FROM		hauptmedia/java:7
MAINTAINER	Julian Haupt <julian.haupt@hauptmedia.de>

ENV		JIRA_VERSION 6.3.14
ENV		MYSQL_CONNECTOR_J_VERSION 5.1.34

ENV		JIRA_HOME     /var/atlassian/application-data/jira
ENV		JIRA_INSTALL_DIR  /opt/atlassian/jira

ENV             RUN_USER            daemon
ENV             RUN_GROUP           daemon

ADD		http://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-${JIRA_VERSION}.tar.gz /tmp/
ADD		http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_CONNECTOR_J_VERSION}.tar.gz /tmp/
ADD		docker-entrypoint.sh /tmp/

RUN		mkdir -p ${JIRA_INSTALL_DIR} && \
		tar -xzf /tmp/atlassian-jira-${JIRA_VERSION}.tar.gz --strip=1 -C ${JIRA_INSTALL_DIR} && \
		echo -e "\njira.home=$JIRA_HOME" >> "${JIRA_INSTALL_DIR}/atlassian-jira/WEB-INF/classes/jira-application.properties" && \
		tar -xzf /tmp/mysql-connector-java-${MYSQL_CONNECTOR_J_VERSION}.tar.gz --strip=1 -C /tmp/ && \
		cp /tmp/mysql-connector-java-${MYSQL_CONNECTOR_J_VERSION}-bin.jar ${JIRA_INSTALL_DIR}/lib && \
		mv /tmp/docker-entrypoint.sh ${JIRA_INSTALL_DIR}/bin && \
		chown -R ${RUN_USER}:${RUN_GROUP} ${JIRA_INSTALL_DIR} && \
		rm -rf /tmp/*

USER            ${RUN_USER}:${RUN_GROUP}

EXPOSE		8080

VOLUME		["${JIRA_INSTALL_DIR}"]

WORKDIR		${JIRA_INSTALL_DIR}
ENTRYPOINT	["bin/docker-entrypoint.sh"]
CMD		["bin/start-jira.sh", "-fg"]
