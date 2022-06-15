FROM --platform=linux/amd64 rockylinux:8 as stage-amd64

FROM --platform=linux/arm64/v8 rockylinux:8 as stage-arm64

ARG TARGETARCH

FROM stage-${TARGETARCH} as final

COPY . /build
RUN /build/install.sh && rm -rf /build
