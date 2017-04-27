#!/bin/bash

# WARNING: if you change this file your GOCD server will be
# wiped and recreated from SCRATCH

# some deps
apt update
apt install software-properties-common git apt-transport-https dnsutils -y
apt install build-essential curl m4 ruby texinfo libbz2-dev libcurl4-openssl-dev libexpat-dev libncurses-dev zlib1g-dev -y


# nodeJS
curl -o- https://deb.nodesource.com/setup_7.x | bash
apt update
apt install nodejs -y


# java
echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" >> /etc/apt/sources.list.d/webupd8team-java.list
echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" >> /etc/apt/sources.list.d/webupd8team-java.list
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886
# accept agreement
echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections
apt update
apt install oracle-java8-installer oracle-java8-set-default -y
java -version
javac -version


# nginx
echo "deb http://nginx.org/packages/debian/ jessie nginx" >> /etc/apt/sources.list.d/nginx.list
echo "deb-src http://nginx.org/packages/debian/ jessie nginx" >> /etc/apt/sources.list.d/nginx.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABF5BD827BD9BF62
apt update
apt install nginx -y
openssl dhparam 2048 -out /etc/nginx/dhparam.pem


# gocd
echo "deb https://download.gocd.io /" > /etc/apt/sources.list.d/gocd.list
curl https://download.gocd.io/GOCD-GPG-KEY.asc | apt-key add -
apt update 
apt install go-server go-agent -y
# start
/etc/init.d/go-server start
/etc/init.d/go-agent start
# set admin password
ADMIN_PASSWORD="cdpasswd"
echo "admin:$(python -c "import sha;from base64 import b64encode;print b64encode(sha.new('$ADMIN_PASSWORD').digest())")" > /etc/go/passwd
sed -i -E "s/<server( .*?)\/>/<server \1>\n    <security>\n      <passwordFile path='\/etc\/go\/passwd' \/>\n    <\/security>\n  <\/server>/" /etc/go/cruise-config.xml
# restart
/etc/init.d/go-server restart


# initial nginx http config. Https config will come later
cat > /etc/nginx/conf.d/default.conf <<EOF
# default server redirects to https except for .well-known
server {
        listen [::]:80;
        listen      80;

        location / {
                return 301 https://\$host\$request_uri;
        }

        location /.well-known {
                root /usr/share/nginx/html;
        }
}

EOF
# restart nginx
/etc/init.d/nginx restart

