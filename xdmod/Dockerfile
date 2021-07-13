ARG HPCTS_VERSION=latest

FROM ubccr/hpcts:slurm-${HPCTS_VERSION}
COPY . /build
RUN /build/install.sh && rm -rf /build
COPY conf/httpd.conf /etc/httpd/conf.d/xdmod.conf
COPY conf/simplesamlphp /etc/xdmod/simplesamlphp
COPY hierarchy.csv /srv/xdmod/hierarchy.csv
COPY historical/ /srv/xdmod/historical
COPY scripts/ /srv/xdmod/scripts
COPY bin/sendmail /usr/sbin/sendmail
COPY bin/xdmod-reset /usr/local/bin/xdmod-reset
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY small-logo.png /srv/xdmod/small-logo.png
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
