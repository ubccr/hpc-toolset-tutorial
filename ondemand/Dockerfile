ARG HPCTS_VERSION=latest

FROM ubccr/hpcts:slurm-${HPCTS_VERSION}
COPY . /build
RUN /build/install.sh && rm -rf /build
COPY cluster-config.yml /etc/ood/config/clusters.d/hpc.yml
COPY bc_desktop.yml /etc/ood/config/apps/bc_desktop/hpc.yml
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
