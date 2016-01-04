# OpenHAB 2.0.0
# * configuration is injected
#
FROM armv7/armhf-java8
MAINTAINER Florian Barth

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
	&& apt-get install -y \
						supervisor \
						unzip \
						wget \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

ENV OPENHAB_VERSION SNAPSHOT 
#ENV OPENHAB_VERSION 2.0.0.alpha2

#
# Install OpenHAB2 runtime
#
RUN echo "Downloading OpenHAB2 runtime..." \
	&& wget --quiet --no-cookies -O /tmp/runtime.zip https://openhab.ci.cloudbees.com/job/openHAB2/lastSuccessfulBuild/artifact/distribution/target/distribution-2.0.0-SNAPSHOT-runtime.zip \
	&& echo "Extracting OpenHAB2 runtime..." \
	&& mkdir -p /opt/openhab \
	&& unzip -q -d /opt/openhab /tmp/runtime.zip \
	&& rm /tmp/runtime.zip \
	&& rm /opt/openhab/*.bat \
	&& mv /opt/openhab/conf /etc/openhab \
	&& ln -s /etc/openhab /opt/openhab/conf \
	&& mkdir -p /opt/openhab/userdata \
	&& chmod +x /opt/openhab/start.sh \
	&& chmod +x /opt/openhab/start_debug.sh \
	&& touch /opt/openhab/conf/DEMO_MODE \
	&& mkdir -p /opt/openhab/logs

#
# Install OpenHAB2 addons
#
RUN echo "Downloading OpenHAB2 addons..." \
	&& wget --quiet --no-cookies -O /tmp/addons.zip https://openhab.ci.cloudbees.com/job/openHAB2/lastSuccessfulBuild/artifact/distribution/target/distribution-2.0.0-SNAPSHOT-addons.zip \
	&& echo "Extracting OpenHAB2 addons..." \
	&& mkdir -p /opt/openhab/addons \
	&& mkdir -p /opt/openhab/addons-available \
	&& unzip -q -d /opt/openhab/addons-available /tmp/addons.zip \
	&& rm /tmp/addons.zip
	
#
# Download OpenHAB2 demo configuration
#
RUN "Downloading OpenHAB2 demo..." \
	&& wget --quiet --no-cookies -O /tmp/demo.zip https://openhab.ci.cloudbees.com/job/openHAB2/lastSuccessfulBuild/artifact/distribution/target/distribution-2.0.0-SNAPSHOT-demo.zip \
	&& echo "Extracting OpenHAB2 demo..." \
	&& mkdir /opt/openhab/demo-configuration \
	&& unzip -q -d /opt/openhab/demo-configuration /tmp/demo.zip \
	&& rm /tmp/demo.zip

#
# Download HABMin2
#
RUN echo "Downloading HABMin2..." \
	&& wget -q -P /opt/openhab/addons-available/addons/ https://github.com/cdjackson/HABmin2/releases/download/0.0.15/org.openhab.ui.habmin_2.0.0.SNAPSHOT-0.0.15.jar 

#
# Download Openhab 1.x dependencies
#
RUN echo "Downloading OpenHAB 1.x dependencies..." \
	&& wget -q -P /tmp/ https://openhab.ci.cloudbees.com/job/openHAB/lastStableBuild/artifact/distribution/target/distribution-1.8.0-SNAPSHOT-addons.zip \
	&& wget -q -P /tmp/ https://openhab.ci.cloudbees.com/job/openHAB/lastStableBuild/artifact/distribution/target/distribution-1.8.0-SNAPSHOT-runtime.zip \
	&& echo "Extracting OpenHAB 1.x dependencies..." \
	&& mkdir -p /opt/openhab/addons-available-oh1 \
    && unzip -q /tmp/distribution-1.8.0-SNAPSHOT-addons.zip -d /opt/openhab/addons-available-oh1 \
    && unzip -j /tmp/distribution-1.8.0-SNAPSHOT-runtime.zip server/plugins/org.openhab.io.transport.mqtt* -d /opt/openhab/addons-available-oh1/ \
    && unzip -j /tmp/distribution-1.8.0-SNAPSHOT-runtime.zip configurations/openhab_default.cfg -d /opt/openhab/ \
    && rm -f /opt/openhab/runtime/server/plugins/org.openhab.io.transport.mqtt* \
    && rm /tmp/distribution-1.8.0-*

#
# Setup other configuration files and scripts
#
COPY files/pipework /usr/local/bin/pipework
COPY files/supervisord.conf /etc/supervisor/supervisord.conf
COPY files/openhab.conf /etc/supervisor/conf.d/openhab.conf
COPY files/openhab_debug.conf /etc/supervisor/conf.d/openhab_debug.conf
COPY files/boot.sh /usr/local/bin/boot.sh
COPY files/openhab-restart /etc/network/if-up.d/openhab-restart

EXPOSE 8080 8443 5555 9001

CMD ["/usr/local/bin/boot.sh"]
