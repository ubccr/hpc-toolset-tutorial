ARG HPCUTIL_VERSION=latest

FROM hpcutil-slurm:$HPCUTIL_VERSION
COPY . /build
RUN /build/install.sh && rm -rf /build
COPY cluster-config.yml /etc/ood/config/clusters.d/linux.yml
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
