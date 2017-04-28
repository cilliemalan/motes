FROM ubuntu:16.04

# loosely based on https://github.com/kubernetes/contrib/blob/master/statefulsets/zookeeper/Dockerfile

# arguments
ARG ZK_DIST=zookeeper-3.4.9

# ports
EXPOSE 2888 3888 2181

# some deps
RUN \
    echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" >> /etc/apt/sources.list.d/webupd8team-java.list && \
    echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" >> /etc/apt/sources.list.d/webupd8team-java.list && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886 && \
    echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
    echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections && \
    apt-get update && \
    apt-get install oracle-java8-installer oracle-java8-set-default -y && \
    java -version && \
    javac -version && \
    wget -q "http://www.apache.org/dist/zookeeper/$ZK_DIST/$ZK_DIST.tar.gz" && \
    tar -xzf "$ZK_DIST.tar.gz" -C /opt && \
    ln -s /opt/$ZK_DIST /opt/zookeeper && \
    useradd zookeeper && \
    mkdir -p /var/lib/zookeeper/data && \
    mkdir -p /var/lib/zookeeper/log && \
    mkdir -p /var/log/zookeeper && \
    mkdir -p /usr/share/zookeeper && \
    mkdir -p /tmp/zookeeper && \
    mkdir -p /usr/etc && \
    chown -R "zookeeper:zookeeper" \
        /opt/$ZK_DIST \
        /var/lib/zookeeper \
        /usr/share/zookeeper \
        /tmp/zookeeper && \
    ln -s /opt/zookeeper/conf/ /usr/etc/zookeeper && \
	ln -s /opt/zookeeper/bin/* /usr/bin && \
	ln -s /opt/zookeeper/$ZK_DIST.jar /usr/share/zookeeper/ && \
	ln -s /opt/zookeeper/lib/* /usr/share/zookeeper

# configuration for ZK
COPY zoo.conf java.env /opt/zookeeper/conf/

# some helper scripts
COPY zkOk.sh zkStats.sh /opt/zookeeper/bin/

# entrypoint
WORKDIR /opt/zookeeper
CMD ["sudo", "-u", "zookeeper", "bin/zkServer.sh start-foreground"]