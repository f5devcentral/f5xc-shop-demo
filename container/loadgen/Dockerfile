FROM loadimpact/k6:0.32.0
USER root

RUN apk -U upgrade && \
    apk --no-cache add tor privoxy curl && \
    rm -rf /var/cache/apk/* 

ENV HTTP_PROXY=http://localhost:8118 HTTPS_PROXY=http://localhost:8118

COPY torrc /etc/tor/
COPY --chown=1001:1 config /tmp/privoxy/config

USER 1001
WORKDIR /home/user
COPY *.js* ./
COPY config .
COPY entrypoint.sh .

ENTRYPOINT ["/home/user/entrypoint.sh"]