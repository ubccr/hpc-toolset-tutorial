ARG HPCTS_VERSION=latest

FROM --platform=linux/amd64 ubccr/hpcts:base-${HPCTS_VERSION} as stage-amd64

FROM --platform=linux/arm64 ubccr/hpcts:base-${HPCTS_VERSION} as stage-arm64

ARG TARGETARCH

FROM stage-${TARGETARCH} as final

ARG SLURM_VERSION
COPY . /build
RUN /build/install.sh && rm -rf /build
COPY slurm.conf /etc/slurm/slurm.conf
COPY --chown=slurm:slurm slurmdbd.conf /etc/slurm/slurmdbd.conf
RUN chmod 600 /etc/slurm/slurmdbd.conf
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY pmlogger-supremm.config /etc/pcp/pmlogger/pmlogger-supremm.config
COPY slurm-prolog.sh /usr/local/bin/slurm-prolog.sh
COPY slurm-epilog.sh /usr/local/bin/slurm-epilog.sh
COPY submit_jobs.sh /usr/local/bin/submit_jobs.sh
COPY example_job.sbatch /usr/local/bin/example_job.sbatch
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["frontend"]
