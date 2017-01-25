
# Setup useful environment variables
CONF_HOME=/var/atlassian/confluence
CONF_INSTALL=/opt/atlassian/confluence
CONF_VERSION=6.0.4

JAVA_CACERTS=$JAVA_HOME/jre/lib/security/cacerts
CERTIFICATE=$CONF_HOME/certificate


# Install Atlassian Confluence and hepler tools and setup initial home
# directory structure.
set -x \
	&& apt-get purge snapd lxcfs lxc-common lxd lxd-client open-iscsi \
    && apt-get update --quiet \
    && apt-get dist-upgrade -y \
    && apt-get install --quiet --yes --no-install-recommends libtcnative-1 xmlstarlet openjdk-8-jdk-headless \
    && apt-get clean \
    && apt-get autoremove --purge \
    && mkdir -p                "${CONF_HOME}" \
    && chmod -R 700            "${CONF_HOME}" \
    && chown daemon:daemon     "${CONF_HOME}" \
    && mkdir -p                "${CONF_INSTALL}/conf" \
    && curl -Ls                "https://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-${CONF_VERSION}.tar.gz" | tar -xz --directory "${CONF_INSTALL}" --strip-components=1 --no-same-owner \
    && curl -Ls                "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.38.tar.gz" | tar -xz --directory "${CONF_INSTALL}/confluence/WEB-INF/lib" --strip-components=1 --no-same-owner "mysql-connector-java-5.1.38/mysql-connector-java-5.1.38-bin.jar" \
    && chmod -R 700            "${CONF_INSTALL}/conf" \
    && chmod -R 700            "${CONF_INSTALL}/temp" \
    && chmod -R 700            "${CONF_INSTALL}/logs" \
    && chmod -R 700            "${CONF_INSTALL}/work" \
    && chown -R daemon:daemon  "${CONF_INSTALL}/conf" \
    && chown -R daemon:daemon  "${CONF_INSTALL}/temp" \
    && chown -R daemon:daemon  "${CONF_INSTALL}/logs" \
    && chown -R daemon:daemon  "${CONF_INSTALL}/work" \
    && echo -e                 "\nconfluence.home=$CONF_HOME" >> "${CONF_INSTALL}/confluence/WEB-INF/classes/confluence-init.properties" \
    && xmlstarlet              ed --inplace \
        --delete               "Server/@debug" \
        --delete               "Server/Service/Connector/@debug" \
        --delete               "Server/Service/Connector/@useURIValidationHack" \
        --delete               "Server/Service/Connector/@minProcessors" \
        --delete               "Server/Service/Connector/@maxProcessors" \
        --delete               "Server/Service/Engine/@debug" \
        --delete               "Server/Service/Engine/Host/@debug" \
        --delete               "Server/Service/Engine/Host/Context/@debug" \
                               "${CONF_INSTALL}/conf/server.xml" \
    && touch -d "@0"           "${CONF_INSTALL}/conf/server.xml" \

if [[ ! -L "$CONF_HOME" ]]; then
	rmdir --ignore-fail-on-non-empty $CONF_HOME
fi
if [[ ! -d "$CONF_HOME" ]]; then
	mkdir -p /data/conf
	ln -s /data/conf/ "$CONF_HOME"
fi


if [[ ! -L "$CONF_INSTALL/logs" ]]; then
	rmdir --ignore-fail-on-non-empty "$CONF_INSTALL/logs"
fi
if [[ ! -d "$CONF_INSTALL/logs" ]]; then
	mkdir -p /data/logs
	ln -s /data/logs/ "$CONF_INSTALL/logs"
fi

crontab -u user -r 
echo "sudo -u daemon /opt/atlassian/confluence/bin/catalina.sh run" | crontab -u user -