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
RUN /build/install.sh && rm -rf /build
COPY cluster-config.yml /etc/ood/config/clusters.d/hpc.yml
COPY bc_desktop.yml /etc/ood/config/apps/bc_desktop/hpc.yml
COPY jupyter /var/www/ood/apps/sys/jupyter
COPY python_job_template /etc/ood/config/apps/myjobs/templates/python
COPY motd /etc/motd
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY notebook_data /data/notebook_data
COPY initializers /etc/ood/config/apps/dashboard/initializers
COPY config/dashboard/env /etc/ood/config/apps/dashboard/env
COPY config/ondemand.yml /etc/ood/config/ondemand.d/ondemand.yml
COPY config/dashboard/widgets /etc/ood/config/apps/dashboard/views/widgets

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
