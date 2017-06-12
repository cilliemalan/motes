FROM influxdb:alpine

# influxdb must have auth
ENV INFLUXDB_HTTP_AUTH_ENABLED true

# our start script
COPY start.sh /start.sh
CMD ["/start.sh"]