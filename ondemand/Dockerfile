ARG HPCTS_VERSION=latest

FROM --platform=linux/amd64 ubccr/hpcts:slurm-${HPCTS_VERSION} AS stage-amd64
RUN dnf -y module reset ruby nodejs
RUN dnf install -y netcat

ARG TARGETARCH

FROM stage-${TARGETARCH} AS final

COPY . /build
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
