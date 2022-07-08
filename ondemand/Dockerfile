ARG HPCTS_VERSION=latest

FROM --platform=linux/amd64 ubccr/hpcts:slurm-${HPCTS_VERSION} as stage-amd64
RUN dnf install -y https://yum.osc.edu/ondemand/2.0/ondemand-release-web-2.0-1.noarch.rpm
RUN dnf install -y netcat ondemand ondemand-dex
RUN sed -i 's/\-nohttpd//' /opt/ood/ondemand/root/usr/share/gems/2.7/ondemand/2.0.27/gems/ood_core-0.19.0/lib/ood_core/batch_connect/templates/vnc.rb

FROM --platform=linux/arm64 ubccr/hpcts:slurm-${HPCTS_VERSION} as stage-arm64
RUN dnf install -y file lsof sudo gcc gcc-c++ git \
        patch lua-posix rsync ruby ruby-devel python2 python3 \
        nodejs sqlite sqlite-devel nmap-ncat httpd httpd-devel mod_ssl \
        libcurl-devel autoconf openssl-devel jansson-devel libxml2-devel \
        libxslt-devel gd-devel libaio-devel
RUN gem install rake dotenv bcrypt
COPY . /build
RUN /build/install-dex-arm64.sh
RUN /build/install-passenger-arm64.sh
RUN /build/install-ood-arm64.sh
RUN sed -i 's/\-nohttpd//' /usr/share/gems/gems/ood_core-0.19.0/lib/ood_core/batch_connect/templates/vnc.rb
RUN rm -rf /build

ARG TARGETARCH

FROM stage-${TARGETARCH} as final

COPY . /build
RUN /build/install.sh && rm -rf /build
COPY cluster-config.yml /etc/ood/config/clusters.d/hpc.yml
COPY bc_desktop.yml /etc/ood/config/apps/bc_desktop/hpc.yml
COPY jupyter /var/www/ood/apps/sys/jupyter
COPY python_job_template /etc/ood/config/apps/myjobs/templates/python
COPY motd /etc/motd
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY notebook_data /data/notebook_data
COPY initializers/dashboard.rb /etc/ood/config/apps/dashboard/initializers/dashboard.rb
COPY themes/hpc-coop /usr/share/ondemand-dex/web/themes/hpc-coop

RUN sed -i '/  passenger_load_shell_envvars off;/a   passenger_preload_bundler on;' /opt/ood/nginx_stage/templates/pun.conf.erb

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
