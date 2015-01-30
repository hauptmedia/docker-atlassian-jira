# docker-atlassian-jira

A docker image for Jira.

## Features

* Based on minimal debian:jessie 
* Uses Oracle Java 7
* Integrates Mysql Connector J driver
* Can be linked to hauptmedia/atlassian-mysql & hauptmedia/atlassian-reverseproxy image for autoconfig

## Example usage

```bash
DOMAIN=example.com
NAME_PREFIX=example

# jira-data
docker run \
--name ${NAME_PREFIX}atlassian-jira-data \
-d \
hauptmedia/atlassian-jira-data

# jira
docker run \
-e JIRA_CONNECTOR_PROXYNAME=jira.$DOMAIN \
-e JIRA_CONNECTOR_PROXYPORT=80 \
-e JIRA_CONNECTOR_SECURE=false \
-e JIRA_CONNECTOR_SCHEME=http \
-e JIRA_CONTEXT_PATH=/ \
--name ${NAME_PREFIX}atlassian-jira \
--volumes-from ${NAME_PREFIX}atlassian-jira-data \
--link ${NAME_PREFIX}atlassian-mysql:mysql \
-d \
hauptmedia/atlassian-jira
```

### Persistent data

#### Use data-only container

```bash
docker run --name atlassian-jira-data -d hauptmedia/atlassian-jira-data
docker run --name atlassian-jira --volumes-from atlassian-jira-data -d hauptmedia/atlassian-jira
```

### Database

#### Link to atlassian-mysql image

```bash
docker run --link atlassian-mysql:mysql -d hauptmedia/atlassian-jira
```

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


