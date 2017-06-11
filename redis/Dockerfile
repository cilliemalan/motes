FROM redis:alpine

# our config
COPY redis.conf /usr/local/etc/redis/redis.conf

# our start script
COPY start.sh /
RUN chmod +x /start.sh

CMD [ "/start.sh"]
