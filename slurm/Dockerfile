ARG HPCTS_VERSION=latest

FROM --platform=linux/amd64 ubccr/hpcts:base-${HPCTS_VERSION} AS stage-amd64

ARG TARGETARCH

FROM stage-${TARGETARCH} AS final

ARG SLURM_VERSION
COPY . /build
RUN /build/install.sh && rm -rf /build
COPY slurm.conf /etc/slurm/slurm.conf
COPY --chown=slurm:slurm slurmdbd.conf /etc/slurm/slurmdbd.conf
RUN chmod 600 /etc/slurm/slurmdbd.conf
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY submit_jobs.sh /usr/local/bin/submit_jobs.sh
COPY example_job.sbatch /usr/local/bin/example_job.sbatch
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["frontend"]
