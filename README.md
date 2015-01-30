# docker-atlassian-jira

A docker image for Jira.

## Features

* Based on minimal debian:jessie 
* Uses Oracle Java 7
* Integrates Mysql Connector J driver
* Jira reverse proxy settings can be set via environment variables
* Can be linked to **hauptmedia/atlassian-mysql** for MySQL backend autoconfig
* Can be linked from **hauptmedia/atlassian-reverseproxy** for nginx reverse proxy autoconfig

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
-e CONNECTOR_PROXYNAME=jira.$DOMAIN \
-e CONNECTOR_PROXYPORT=80 \
-e CONNECTOR_SECURE=false \
-e CONNECTOR_SCHEME=http \
-e CONTEXT_PATH=/ \
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

### Database backend

#### Link to hauptmeda/atlassian-mysql image

When this image is linked to the **hauptmedia/atlassian-mysql** image with a local alias named mysql the mysql database will be auto configured in this container.

```bash
docker run --link atlassian-mysql:mysql -d hauptmedia/atlassian-jira
```

### Reverse proxy setup

Jira needs a special setup when it's run behind a reverse proxy. These settings are exposed via the environment variables *CONNECTOR_PROXYNAME*, *CONNECTOR_PROXYPORT*, *CONNECTOR_SECURE*, *CONNECTOR_SCHEME* and *CONTEXT_PATH*.

See http & https examples below.

The documentation of the variables can be found here: https://confluence.atlassian.com/display/JIRA/Integrating+JIRA+with+Apache

Note: if you link the **hauptmedia/atlassian-reverseproxy** container with this container the resulting reverse proxy will be auto configured (it uses the environment variables from this container)

#### http

```bash
docker run -d hauptmedia/atlassian-jira \
-e CONNECTOR_PROXYNAME=jira.example.com \
-e CONNECTOR_PROXYPORT=80 \
-e CONNECTOR_SECURE=false \
-e CONNECTOR_SCHEME=http \
-e CONTEXT_PATH=/
```

#### https

```bash
docker run -d hauptmedia/atlassian-jira \
-e CONNECTOR_PROXYNAME=jira.example.com \
-e CONNECTOR_PROXYPORT=443 \
-e CONNECTOR_SECURE=true \
-e CONNECTOR_SCHEME=https \
-e CONTEXT_PATH=/
```


