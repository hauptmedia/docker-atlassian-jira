# docker-atlassian-jira

A docker image for Jira.

## Features

* Based on minimal debian:jessie 
* Uses Oracle Java 7
* Integrates Mysql Connector J driver

### Reverse proxy setup

#### http

```bash
docker run -d hauptmedia/atlassian-jira \
-e JIRA_CONNECTOR_PROXYNAME=jira.example.com \
-e JIRA_CONNECTOR_PROXYPORT=80 \
-e JIRA_CONNECTOR_SECURE=false \
-e JIRA_CONNECTOR_SCHEME=http \
-e JIRA_CONTEXT_PATH=/
```

#### https

```bash
docker run -d hauptmedia/atlassian-jira \
-e JIRA_CONNECTOR_PROXYNAME=jira.example.com \
-e JIRA_CONNECTOR_PROXYPORT=443 \
-e JIRA_CONNECTOR_SECURE=true \
-e JIRA_CONNECTOR_SCHEME=https \
-e JIRA_CONTEXT_PATH=/
```


