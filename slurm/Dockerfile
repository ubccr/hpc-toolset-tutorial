ARG HPCTS_VERSION=latest

FROM ubccr/hpcts:base-${HPCTS_VERSION}
ARG SLURM_VERSION
COPY . /build
RUN /build/install.sh && rm -rf /build
COPY slurm.conf /etc/slurm/slurm.conf
COPY slurmdbd.conf /etc/slurm/slurmdbd.conf
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY pmlogger-supremm.config /etc/pcp/pmlogger/pmlogger-supremm.config
COPY slurm-prolog.sh /usr/local/bin/slurm-prolog.sh
COPY slurm-epilog.sh /usr/local/bin/slurm-epilog.sh
COPY submit_jobs.sh /usr/local/bin/submit_jobs.sh
COPY example_job.sbatch /usr/local/bin/example_job.sbatch
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["frontend"]
