#!/bin/sh

if [ -z "$JIRA_INSTALL_DIR" ]; then
	echo Missing JIRA_INSTALL_DIR env
	exit 1
fi

if [ -z "$JIRA_HOME" ]; then
	echo Missing JIRA_HOME env
	exit 1
fi

if [ -n "$MYSQL_NAME" ]; then 
	if [ -z "$MYSQL_ENV_MYSQL_JIRA_USER" ]; then
		echo Missing MYSQL_JIRA_USER environment variable from docker container named mysql
		exit 1
	fi

	if [ -z "$MYSQL_ENV_MYSQL_JIRA_PASSWORD" ]; then
		echo Missing MYSQL_JIRA_PASSWORD environment variable from docker container named mysql
		exit 1
	fi

	if [ -z "$MYSQL_ENV_MYSQL_JIRA_DATABASE" ]; then
		echo Missing MYSQL_JIRA_DATABASE environment variable from docker container named mysql
		exit 1
	fi

	cat <<EOF >$JIRA_HOME/dbconfig.xml
<?xml version="1.0" encoding="UTF-8"?>
<jira-database-config>
  <name>defaultDS</name>
  <delegator-name>default</delegator-name>
  <database-type>mysql</database-type>
  <schema-name></schema-name>
  <jdbc-datasource>
    <url>jdbc:mysql://$MYSQL_PORT_3306_TCP_ADDR:$MYSQL_PORT_3306_TCP_PORT/$MYSQL_ENV_MYSQL_JIRA_DATABASE?autoReconnect=true&amp;useUnicode=true&amp;characterEncoding=UTF8&amp;sessionVariables=storage_engine=InnoDB</url>
    <driver-class>com.mysql.jdbc.Driver</driver-class>
    <username>${MYSQL_ENV_MYSQL_JIRA_USER}</username>
    <password>${MYSQL_ENV_MYSQL_JIRA_PASSWORD}</password>
    <pool-size>15</pool-size>
    <validation-query>select 1</validation-query>
  </jdbc-datasource>
</jira-database-config>
EOF
fi

if [ -n "$CONNECTOR_PROXYNAME" ]; then
	xmlstarlet ed --inplace --delete "/Server/Service/Connector/@proxyName" $JIRA_INSTALL_DIR/conf/server.xml
	xmlstarlet ed --inplace --insert "/Server/Service/Connector" --type attr -n proxyName -v $CONNECTOR_PROXYNAME $JIRA_INSTALL_DIR/conf/server.xml
fi

if [ -n "$CONNECTOR_PROXYPORT" ]; then
	xmlstarlet ed --inplace --delete "/Server/Service/Connector/@proxyPort" $JIRA_INSTALL_DIR/conf/server.xml
	xmlstarlet ed --inplace --insert "/Server/Service/Connector" --type attr -n proxyPort -v $CONNECTOR_PROXYPORT $JIRA_INSTALL_DIR/conf/server.xml
fi

if [ -n "$CONNECTOR_SECURE" ]; then
	xmlstarlet ed --inplace --delete "/Server/Service/Connector/@secure" $JIRA_INSTALL_DIR/conf/server.xml
	xmlstarlet ed --inplace --insert "/Server/Service/Connector" --type attr -n secure -v $CONNECTOR_SECURE $JIRA_INSTALL_DIR/conf/server.xml
fi

if [ -n "$CONNECTOR_SCHEME" ]; then
	xmlstarlet ed --inplace --delete "/Server/Service/Connector/@scheme" $JIRA_INSTALL_DIR/conf/server.xml
	xmlstarlet ed --inplace --insert "/Server/Service/Connector" --type attr -n scheme -v $CONNECTOR_SCHEME $JIRA_INSTALL_DIR/conf/server.xml
fi

if [ -n "$CONTEXT_PATH" ]; then
	if [ "$CONTEXT_PATH" = "/" ]; then
		CONTEXT_PATH=""
	fi

	xmlstarlet ed --inplace --delete "/Server/Service/Engine/Host/Context/@path" $JIRA_INSTALL_DIR/conf/server.xml
	xmlstarlet ed --inplace --insert "/Server/Service/Engine/Host/Context" --type attr -n path -v "$CONTEXT_PATH" $JIRA_INSTALL_DIR/conf/server.xml
fi
	
exec "$@"

