ARG IMAGE_GOLANG_VERSION=1.27.0-alpine3.24
ARG IMAGE_GOLANG_DIGEST=4c9fe60190a2a3350ddc51de80d0224b8a6698d12bdfc999fee45ea9d6c46dbc
ARG IMAGE_ALPINE_VERSION=3.24.1
ARG IMAGE_ALPINE_DIGEST=28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b

ARG UID=65532
ARG GID=65532

FROM docker.io/library/golang:${IMAGE_GOLANG_VERSION}@sha256:${IMAGE_GOLANG_DIGEST} AS builder

RUN set -e && \
    apk add --no-cache \
    ca-certificates=20260611-r0 \
    git=2.54.0-r0

WORKDIR /src

ARG IMAGE_WGCF_VERSION

RUN set -e && \
    git clone --recurse-submodules -j8 --branch "v${IMAGE_WGCF_VERSION}" https://github.com/ViRb3/wgcf

WORKDIR /src/wgcf

ARG IMAGE_WGCF_COMMIT

RUN set -e && \
    git checkout "$IMAGE_WGCF_COMMIT"

RUN set -e && \
    go mod download && \
    go mod verify

ARG IMAGE_BUILD_TARGET_GOARCH

RUN \
    if [ "${IMAGE_BUILD_TARGET_GOARCH}" = "arm/v6" ]; then export GOARM=6; fi; \
    GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=${IMAGE_BUILD_TARGET_GOARCH} \
    go build \
        -trimpath \
        -buildvcs=false \
        -ldflags="-w -s" \
        -o "wgcf"

FROM docker.io/library/alpine:${IMAGE_ALPINE_VERSION}@sha256:${IMAGE_ALPINE_DIGEST}

ARG IMAGE_VCS_DATE
ARG IMAGE_VCS_REV
ARG IMAGE_WGCF_VERSION
ARG IMAGE_BUILD_REVISION

LABEL org.opencontainers.image.title="ViRb3/wgcf" \
    org.opencontainers.image.vendor="Hantong Chen" \
    org.opencontainers.image.authors="Hantong Chen" \
    org.opencontainers.image.description="Third-party rootless reproducible OCI image of [ViRb3/wgcf](https://github.com/ViRb3/wgcf/)." \
    org.opencontainers.image.documentation="https://github.com/hanyu-dev/oci-image-wgcf/blob/main/README.md" \
    org.opencontainers.image.source="https://github.com/hanyu-dev/oci-image-wgcf" \
    org.opencontainers.image.url="https://github.com/hanyu-dev/oci-image-wgcf" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.created=${IMAGE_VCS_DATE} \
    org.opencontainers.image.version="${IMAGE_WGCF_VERSION}-r${IMAGE_BUILD_REVISION}" \
    org.opencontainers.image.revision=${IMAGE_VCS_REV}

RUN set -e && \
    apk add --no-cache \
    ca-certificates=20260611-r0 \
    wireguard-tools=1.0.20260223-r0

RUN set -e && \
    rm -rf /var/lib/apk/tmp/* /var/cache/apk/* /var/log/apk.log

WORKDIR /app

RUN set -e && \
    mkdir ./config

ARG UID
ARG GID

COPY --from=builder --chmod=0755 /src/wgcf/wgcf ./wgcf
COPY --chmod=0755 ./assets/build/entrypoint.sh ./entrypoint.sh

USER ${UID}:${GID}

ENTRYPOINT ["/app/entrypoint.sh"]
