ARG HPCUTIL_VERSION=latest

FROM hpcutil-slurm:$HPCUTIL_VERSION
COPY . /build
RUN /build/install.sh && rm -rf /build
COPY xdmod-httpd.conf /etc/httpd/conf.d/xdmod.conf
COPY hierarchy.csv /srv/xdmod/hierarchy.csv
COPY scripts/ /srv/xdmod/scripts
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
