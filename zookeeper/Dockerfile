FROM ubuntu:16.04

# loosely based on https://github.com/kubernetes/contrib/blob/master/statefulsets/zookeeper/Dockerfile

# arguments
ARG ZK_DIST=zookeeper-3.4.9

# ports
EXPOSE 2888 3888 2181

# some deps
RUN \
    apt-get update && \
    apt-get install openjdk-8-jre-headless wget netcat-openbsd -y && \
    java -version && \
    javac -version && \
    wget -q "http://www.apache.org/dist/zookeeper/$ZK_DIST/$ZK_DIST.tar.gz" -O "/tmp/$ZK_DIST.tar.gz"  && \
    tar -xzf "/tmp/$ZK_DIST.tar.gz" -C /opt && \
    rm "/tmp/$ZK_DIST.tar.gz" && \
    ln -s /opt/$ZK_DIST /opt/zookeeper && \
    useradd zookeeper && \
    mkdir -p /var/lib/zookeeper/data && \
    mkdir -p /var/lib/zookeeper/log && \
    mkdir -p /var/log/zookeeper && \
    mkdir -p /usr/share/zookeeper && \
    mkdir -p /tmp/zookeeper && \
    mkdir -p /usr/etc && \
    chown -R "zookeeper:zookeeper" \
        "/opt/$ZK_DIST" \
        /var/lib/zookeeper \
        /usr/share/zookeeper \
        /tmp/zookeeper && \
    ln -s /opt/zookeeper/conf/ /usr/etc/zookeeper && \
	ln -s /opt/zookeeper/bin/* /usr/bin && \
	ln -s /opt/zookeeper/$ZK_DIST.jar /usr/share/zookeeper/ && \
	ln -s /opt/zookeeper/lib/* /usr/share/zookeeper && \
    cd /opt/zookeeper && \
    rm -rf CHANGES.txt README.txt NOTICE.txt CHANGES.txt README_packaging.txt build.xml \
            config contrib dist-maven docs ivy.xml ivysettings.xml recipes src \
            $ZK_DIST.jar.asc $ZK_DIST.jar.md5 $ZK_DIST.jar.sha1 && \
    apt-get autoremove -y wget && \
    rm -rf /var/lib/apt/lists/*

# configuration for ZK
COPY zoo.cfg.base java.env /opt/zookeeper/conf/

# some helper scripts
COPY zkOk.sh zkStats.sh zkStart.sh /opt/zookeeper/bin/

# entrypoint
WORKDIR /opt/zookeeper
CMD ["bin/zkStart.sh"]