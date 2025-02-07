ARG HPCTS_VERSION=latest

FROM --platform=linux/amd64 ubccr/hpcts:slurm-${HPCTS_VERSION} AS stage-amd64
RUN dnf config-manager --set-enabled powertools
RUN dnf -y module reset ruby nodejs
RUN dnf -y module enable ruby:3.3 nodejs:20
RUN dnf install -y https://yum.osc.edu/ondemand/4.0/ondemand-release-web-4.0-1.el8.noarch.rpm
RUN dnf install -y netcat ondemand mod_auth_openidc

ARG TARGETARCH

FROM stage-${TARGETARCH} AS final

COPY . /build
RUN /build/install.sh
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
