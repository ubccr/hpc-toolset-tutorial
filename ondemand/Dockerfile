ARG HPCTK_VERSION=latest

FROM hpctk-slurm:$HPCTK_VERSION
COPY . /build
RUN /build/install.sh && rm -rf /build
COPY cluster-config.yml /etc/ood/config/clusters.d/linux.yml
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]