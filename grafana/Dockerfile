FROM grafana/grafana


RUN mkdir /grafanaconf  && \
    cp -R /etc/grafana/* /grafanaconf && \
    ls -la /grafanaconf

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["echo 'starting' && \
    cp -R /grafanaconf/* /etc/grafana && \
    ls -la /etc/grafana && \
    bash /run.sh"]