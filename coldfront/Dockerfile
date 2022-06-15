ARG HPCTS_VERSION=latest

FROM --platform=linux/amd64 ubccr/hpcts:slurm-${HPCTS_VERSION} as stage-amd64

FROM --platform=linux/arm64 ubccr/hpcts:slurm-${HPCTS_VERSION} as stage-arm64

ARG TARGETARCH

FROM stage-${TARGETARCH} as final

COPY . /build
RUN /build/install.sh && rm -rf /build
COPY --chown=coldfront:coldfront local_settings.py /etc/coldfront/local_settings.py
COPY --chown=coldfront:coldfront coldfront.env /etc/coldfront/coldfront.env
COPY --chown=coldfront:coldfront checkdb.py /srv/www/checkdb.py
COPY coldfront-nginx.conf /etc/nginx/conf.d/coldfront.conf
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
