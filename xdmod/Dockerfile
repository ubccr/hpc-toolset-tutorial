ARG HPCTS_VERSION=latest

FROM --platform=linux/amd64 ubccr/hpcts:slurm-${HPCTS_VERSION} as stage-amd64

FROM --platform=linux/arm64 ubccr/hpcts:slurm-${HPCTS_VERSION} as stage-arm64

ARG TARGETARCH

FROM stage-${TARGETARCH} as final

COPY . /build
COPY conf/httpd.conf /etc/httpd/conf.d/xdmod.conf
COPY conf/simplesamlphp /etc/xdmod/simplesamlphp
COPY hierarchy.csv /srv/xdmod/hierarchy.csv
COPY historical/ /srv/xdmod/historical
COPY scripts/ /srv/xdmod/scripts
COPY bin/sendmail /usr/sbin/sendmail
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY small-logo.png /srv/xdmod/small-logo.png
RUN /build/install.sh && rm -rf /build
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
