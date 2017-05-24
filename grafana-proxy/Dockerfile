FROM debian:jessie-backports

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		liblua5.3-0 \
		libpcre3 \
		libssl1.0.0 \
        rsyslog \
	&& rm -rf /var/lib/apt/lists/*

ENV HAPROXY_MAJOR 1.7
ENV HAPROXY_VERSION 1.7.5
ENV HAPROXY_MD5 ed84c80cb97852d2aa3161ed16c48a1c

# see http://sources.debian.net/src/haproxy/jessie/debian/rules/ for some helpful navigation of the possible "make" arguments
RUN set -x \
	\
	&& buildDeps=' \
		gcc \
		libc6-dev \
		liblua5.3-dev \
		libpcre3-dev \
		libssl-dev \
		make \
		wget \
	' \
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends && rm -rf /var/lib/apt/lists/* \
	\
	&& wget -O haproxy.tar.gz "http://cdn.chills.co.za/haproxy-1.7.5.tar.gz" \
	&& echo "$HAPROXY_MD5 *haproxy.tar.gz" | md5sum -c \
	&& mkdir -p /usr/src/haproxy \
	&& tar -xzf haproxy.tar.gz -C /usr/src/haproxy --strip-components=1 \
	&& rm haproxy.tar.gz \
	\
	&& makeOpts=' \
		TARGET=linux2628 \
		USE_LUA=1 LUA_INC=/usr/include/lua5.3 \
		USE_OPENSSL=1 \
		USE_PCRE=1 PCREDIR= \
		USE_ZLIB=1 \
	' \
	&& make -C /usr/src/haproxy -j "$(nproc)" all $makeOpts \
	&& make -C /usr/src/haproxy install-bin $makeOpts \
	\
	&& mkdir -p /usr/local/etc/haproxy \
	&& cp -R /usr/src/haproxy/examples/errorfiles /usr/local/etc/haproxy/errors \
	&& rm -rf /usr/src/haproxy \
	\
	&& apt-get purge -y --auto-remove $buildDeps \
    \
    && sed \
        -e 's/#\$ModLoad imudp/\$ModLoad imudp\n\$UDPServerAddress 127.0.0.1/' \
        -e 's/#\$UDPServerRun 514/\$UDPServerRun 514/' \
        -i /etc/rsyslog.conf \
    && echo 'if ($programname == "haproxy") then -/var/log/haproxy.log' >> /etc/rsyslog.conf \
    && touch /var/log/haproxy.log \
    \
    service rsyslog restart



COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg


COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["haproxy", "-f", "/usr/local/etc/haproxy/haproxy.cfg"]
