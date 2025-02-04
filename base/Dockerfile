FROM --platform=linux/amd64 rockylinux:8 AS stage-amd64

FROM --platform=linux/arm64/v8 rockylinux:8 AS stage-arm64

ARG TARGETARCH

FROM stage-${TARGETARCH} AS final

COPY . /build
RUN /build/install.sh && rm -rf /build
