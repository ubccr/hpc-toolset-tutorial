ARG SLURM_VERSION=20.02.3

FROM centos:7 AS base
COPY . /build
RUN /build/base/install.sh && rm -rf /build

FROM base AS slurm
COPY . /build
RUN /build/slurm/install.sh && rm -rf /build
COPY slurm/slurm.conf /etc/slurm/slurm.conf
COPY slurm/slurmdbd.conf /etc/slurm/slurmdbd.conf
COPY slurm/entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["frontend"]

FROM slurm:$SLURM_VERSION AS coldfront
COPY . /build
RUN /build/coldfront/install.sh && rm -rf /build
COPY --chown=coldfront:coldfront coldfront/local_settings.py /srv/www/coldfront/coldfront/config/local_settings.py
COPY --chown=coldfront:coldfront coldfront/local_strings.py /srv/www/coldfront/coldfront/config/local_strings.py
COPY --chown=coldfront:coldfront coldfront/checkdb.py /srv/www/checkdb.py
COPY coldfront/coldfront-nginx.conf /etc/nginx/conf.d/coldfront.conf
COPY coldfront/entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
