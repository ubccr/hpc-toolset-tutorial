ARG HPCTS_VERSION=latest

FROM ubccr/hpcts:slurm-${HPCTS_VERSION}
COPY . /build
RUN /build/install.sh && rm -rf /build
COPY --chown=coldfront:coldfront local_settings.py /etc/coldfront/local_settings.py
COPY --chown=coldfront:coldfront coldfront.env /etc/coldfront/coldfront.env
COPY --chown=coldfront:coldfront checkdb.py /srv/www/checkdb.py
COPY coldfront-nginx.conf /etc/nginx/conf.d/coldfront.conf
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
