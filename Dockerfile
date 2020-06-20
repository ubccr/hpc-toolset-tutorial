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
