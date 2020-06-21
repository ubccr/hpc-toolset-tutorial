ARG HPCTK_VERSION=latest

FROM hpctk-slurm:$HPCTK_VERSION
COPY . /build
RUN /build/install.sh && rm -rf /build
COPY --chown=coldfront:coldfront local_settings.py /srv/www/coldfront/coldfront/config/local_settings.py
COPY --chown=coldfront:coldfront local_strings.py /srv/www/coldfront/coldfront/config/local_strings.py
COPY --chown=coldfront:coldfront checkdb.py /srv/www/checkdb.py
COPY coldfront-nginx.conf /etc/nginx/conf.d/coldfront.conf
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
