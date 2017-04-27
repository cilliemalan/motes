#!/bin/bash

sudo -H /bin/bash - <<'eofscript'

# certbot (letsencrypt certificates)
wget https://dl.eff.org/certbot-auto -O /usr/sbin/certbot-auto
chmod a+x /usr/sbin/certbot-auto
# bootstrap certbot-auto
certbot-auto -q
# for certbot webroot plugin
mkdir /usr/share/nginx/html/.well-known
# some vars
DNS_NAME=`curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/dns" -H "Metadata-Flavor: Google"`
EMAIL=`curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/email" -H "Metadata-Flavor: Google"`
# register with letsencrypt
certbot-auto register --agree-tos -m "$EMAIL" --non-interactive
# run certbot now just in case it works
certbot-auto certonly --webroot -w /usr/share/nginx/html -d "$DNS_NAME" --non-interactive
# add cron job to renew
echo "23 3,15 * * * root certbot-auto renew --quiet --no-self-upgrade --renew-hook \"/etc/init.d/nginx restart\"" > /etc/cron.d/certbot


# overwrite nginx config
DNS_NAME=`curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/dns" -H "Metadata-Flavor: Google"`
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



# ssl server proxy passes to gocd and has A+ rating on https://www.ssllabs.com/ssltest/
server {
        listen [::]:443 default_server ssl http2;
        listen      443 default_server ssl http2;

        server_name $DNS_NAME;

        ssl_certificate /etc/letsencrypt/live/$DNS_NAME/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/$DNS_NAME/privkey.pem;
        ssl_trusted_certificate /etc/letsencrypt/live/$DNS_NAME/chain.pem;
        ssl_dhparam /etc/nginx/dhparam.pem;
        ssl_protocols TLSv1.2 TLSv1.1 TLSv1;
        ssl_prefer_server_ciphers on;
        ssl_ciphers ECDH+AESGCM:ECDH+AES256:ECDH+AES128:DH+3DES:!ADH:!AECDH:!MD5;
        ssl_session_cache shared:SSL:20m;
        ssl_session_timeout 180m;
        ssl_stapling on;
        ssl_stapling_verify on;

        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

        resolver 8.8.8.8 8.8.4.4;

        location / {
            proxy_pass              http://127.0.0.1:8153/;
            proxy_set_header        Host            \$host;
            proxy_set_header        X-Real-IP       \$remote_addr;
            proxy_set_header        X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header        X-Forwarded-Proto \$scheme;
        }
}

EOF

# restart nginx
/etc/init.d/nginx restart

# stuff will reside here:
# Cert: /etc/letsencrypt/live/gocd.cd-example.com/fullchain.pem
# Chain: /etc/letsencrypt/live/gocd.cd-example.com/chain.pem
# Key: /etc/letsencrypt/live/gocd.cd-example.com/privkey.pem


eofscript

