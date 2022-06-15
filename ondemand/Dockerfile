ARG HPCTS_VERSION=latest

FROM --platform=linux/amd64 ubccr/hpcts:slurm-${HPCTS_VERSION} as stage-amd64

FROM --platform=linux/arm64 ubccr/hpcts:slurm-${HPCTS_VERSION} as stage-arm64

ARG TARGETARCH

FROM stage-${TARGETARCH} as final

COPY . /build
RUN /build/install.sh && rm -rf /build
COPY cluster-config.yml /etc/ood/config/clusters.d/hpc.yml
COPY bc_desktop.yml /etc/ood/config/apps/bc_desktop/hpc.yml
COPY jupyter /var/www/ood/apps/sys/jupyter
COPY python_job_template /etc/ood/config/apps/myjobs/templates/python
COPY motd /etc/motd
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY notebook_data /data/notebook_data
COPY initializers/dashboard.rb /etc/ood/config/apps/dashboard/initializers/dashboard.rb
COPY themes/hpc-coop /usr/share/ondemand-dex/web/themes/hpc-coop

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
