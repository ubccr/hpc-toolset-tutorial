ARG HPCTS_VERSION=latest

FROM hpcts-base:$HPCTS_VERSION
ARG SLURM_VERSION
COPY . /build
RUN /build/install.sh && rm -rf /build
COPY slurm.conf /etc/slurm/slurm.conf
COPY slurmdbd.conf /etc/slurm/slurmdbd.conf
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["frontend"]
