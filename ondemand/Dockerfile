ARG SLURM_VERSION=20.02.3

FROM slurm:$SLURM_VERSION
COPY . /build
RUN /build/ondemand/install.sh && rm -rf /build
COPY ondemand/cluster-config.yml /etc/ood/config/clusters.d/linux.yml
COPY ondemand/entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
