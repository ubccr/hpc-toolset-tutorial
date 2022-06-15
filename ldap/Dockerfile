FROM --platform=linux/amd64 osixia/openldap:1.5.0 as stage-amd64

FROM --platform=linux/arm64/v8 osixia/openldap:1.5.0 as stage-arm64

ARG TARGETARCH

FROM stage-${TARGETARCH} as final

COPY . /build
RUN /build/install.sh && rm -rf /build
