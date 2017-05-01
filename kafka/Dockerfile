FROM ubuntu:16.04

# get kafka
RUN \
    apt-get update && \
    apt-get install openjdk-8-jre-headless wget netcat-openbsd -y && \
    java -version && \
    wget -q "http://www-eu.apache.org/dist/kafka/0.10.2.1/kafka_2.12-0.10.2.1.tgz" \
        -O "/tmp/kafka_2.12-0.10.2.1.tgz"  && \
    tar -xzf "/tmp/kafka_2.12-0.10.2.1.tgz" -C /opt && \
    rm "/tmp/kafka_2.12-0.10.2.1.tgz" && \
    ln -s /opt/kafka_2.12-0.10.2.1 /opt/kafka && \
    useradd kafka && \
    mkdir /var/lib/kafka && \
    mkdir /var/lib/kafka/logs && \
    chown -R "kafka:kafka" /var/lib/kafka /opt/kafka && \
    sed -i \
        -e "s/log.dirs=.*/log.dirs=\/var\/lib\/kafka\/logs/" \
        -e "s/zookeeper.connect=.*/zookeeper.connect=zookeeper:2181/" \
        -e "s/#listeners=.*/listeners=PLAINTEXT:\/\/:9092/" \
        /opt/kafka/config/server.properties

# start script
COPY kafka-start.sh /opt/kafka/bin/
RUN chmod +x /opt/kafka/bin/kafka-start.sh

# expose the listener port
EXPOSE 9092


# entry point
WORKDIR /opt/kafka
CMD ["bin/kafka-start.sh"]
