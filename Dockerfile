ARG IMAGE_ALPINE_VERSION=3.24.1
ARG IMAGE_ALPINE_DIGEST=28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b

ARG UID=65532
ARG GID=65532

FROM docker.io/library/alpine:${IMAGE_ALPINE_VERSION}@sha256:${IMAGE_ALPINE_DIGEST} AS downloader

RUN <<EOF
set -e
apk add --no-cache ca-certificates=20260909-r0
apk add --no-cache wget=1.25.0-r3
EOF

RUN rm -rf /var/lib/apk/tmp/* /var/cache/apk/* /var/log/apk.log

WORKDIR /opt/sing-box

ARG IMAGE_SING_BOX_VERSION
ARG IMAGE_BUILD_TARGET_GOARCH

RUN <<EOF
set -e
wget -q -O ./sing-box.tar.gz "https://github.com/SagerNet/sing-box/releases/download/v${IMAGE_SING_BOX_VERSION}/sing-box-${IMAGE_SING_BOX_VERSION}-linux-${IMAGE_BUILD_TARGET_GOARCH}-musl.tar.gz"
tar -xzf ./sing-box.tar.gz --strip-components=1 -C ./
rm ./sing-box.tar.gz
EOF

FROM docker.io/library/alpine:${IMAGE_ALPINE_VERSION}@sha256:${IMAGE_ALPINE_DIGEST}

ARG IMAGE_VCS_DATE
ARG IMAGE_VCS_REV
ARG IMAGE_SING_BOX_VERSION
ARG IMAGE_BUILD_REVISION

LABEL org.opencontainers.image.title="sing-box" \
    org.opencontainers.image.vendor="Hantong Chen" \
    org.opencontainers.image.authors="Hantong Chen" \
    org.opencontainers.image.description="Third-party rootless reproducible OCI image of [sing-box](https://github.com/SagerNet/sing-box)." \
    org.opencontainers.image.documentation="https://github.com/hanyu-dev/oci-image-sing-box/blob/main/README.md" \
    org.opencontainers.image.source="https://github.com/hanyu-dev/oci-image-sing-box" \
    org.opencontainers.image.url="https://github.com/hanyu-dev/oci-image-sing-box" \
    org.opencontainers.image.licenses="GPL-3.0-or-later" \
    org.opencontainers.image.created=${IMAGE_VCS_DATE} \
    org.opencontainers.image.version=${IMAGE_SING_BOX_VERSION}-r${IMAGE_BUILD_REVISION} \
    org.opencontainers.image.revision=${IMAGE_VCS_REV}

RUN <<EOF
set -e
apk add --no-cache ca-certificates=20260909-r0
EOF

RUN rm -rf /var/lib/apk/tmp/* /var/cache/apk/* /var/log/apk.log

COPY --from=downloader --chown="0:0" --chmod=775 /opt/sing-box /opt/sing-box

WORKDIR /opt/sing-box

ARG UID

ARG GID

USER ${UID}:${GID}

ENTRYPOINT ["/opt/sing-box/sing-box"]
