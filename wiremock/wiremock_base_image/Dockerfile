FROM openjdk:8-jre

LABEL Rodolphe CHAIGNEAU <rodolphe.chaigneau@gmail.com>

# Install apt-transport-https; otherwise, custom APT https repositories will not work.
RUN apt-get update \
    && apt-get install -y apt-transport-https apt-utils software-properties-common

ENV WIREMOCK_VERSION 2.27.2
ENV GOSU_VERSION 1.10

# grab gosu for easy step-down from root
RUN set -x \
  && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
  && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
  && export GNUPGHOME="$(mktemp -d)" \
  && for server in $(shuf -e ha.pool.sks-keyservers.net \
    hkp://p80.pool.sks-keyservers.net:80 \
    keyserver.ubuntu.com \
    hkp://keyserver.ubuntu.com:80 \
    pgp.mit.edu) ; do \
    gpg --batch --keyserver "$server" --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && break || : ; \
    done \
  && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
  && rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc \
  && chmod +x /usr/local/bin/gosu \
  && gosu nobody true

# grab wiremock standalone jar
RUN mkdir -p /var/wiremock/lib/ \
  && wget https://repo1.maven.org/maven2/com/github/tomakehurst/wiremock-standalone/$WIREMOCK_VERSION/wiremock-standalone-$WIREMOCK_VERSION.jar \
    -O /var/wiremock/lib/wiremock-standalone.jar

WORKDIR /home/wiremock

COPY docker-entrypoint.sh /

RUN chmod +x /docker-entrypoint.sh

VOLUME /home/wiremock
EXPOSE 8080 8443

# Add desired extension
# ADD https://repo1.maven.org/maven2/org/wiremock/wiremock-webhooks-extension/1.0.0/wiremock-webhooks-extension-1.0.0.jar /var/wiremock/extensions/
# ADD https://repo1.maven.org/maven2/org/apache/httpcomponents/httpclient/4.5.13/httpclient-4.5.13.jar /var/wiremock/extensions/
# ADD https://repo1.maven.org/maven2/org/apache/httpcomponents/httpcore/4.4.14/httpcore-4.4.14.jar /var/wiremock/extensions/
ADD https://repo1.maven.org/maven2/com/opentable/wiremock-body-transformer/1.1.3/wiremock-body-transformer-1.1.3.jar /var/wiremock/extensions/

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["java", "-cp", "/var/wiremock/lib/*:/var/wiremock/extensions/*", "com.github.tomakehurst.wiremock.standalone.WireMockServerRunner", "--extensions", "com.opentable.extension.BodyTransformer"]
