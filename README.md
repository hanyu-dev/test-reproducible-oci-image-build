# oci-image-wgcf

Third-party rootless reproducible OCI image of [ViRb3/wgcf](https://github.com/ViRb3/wgcf/).

## Reproducibility

To verify the reproducibility of the build, you can use the following command to build the image locally and compare the digest with the one published on GitHub Container Registry (ghcr.io).

```bash
export IMAGE_NAME=hanyu-dev/oci-image-wgcf
export IMAGE_REGISTRY=ghcr.io
export IMAGE_BUILD_TARGET_GOARCHS=amd64,arm64,loong64

# See .github/workflows/build-image.yaml
export IMAGE_WGCF_VERSION=2.2.32
export IMAGE_WGCF_COMMIT=7947653aaa4b7a793a28603548c5f86449efc615
export IMAGE_BUILD_REVISION=0

# See .github/workflows/build-image.yaml
export IMAGE_BUILDAH_VERSION=1.43.2-immutable
export IMAGE_BUILDAH_DIGEST=19ee6da290f77e63ab7f108a1b22e63d4c36cb827fba9f494982c5ceeba27019

podman run \
    --rm -it \
    --device /dev/fuse \
    --security-opt label=disable \
    -v "$PWD:/workspace" \
    -w /workspace \
    -e IMAGE_NAME="${IMAGE_NAME}" \
    -e IMAGE_REGISTRY="${IMAGE_REGISTRY}" \
    -e IMAGE_BUILD_TARGET_GOARCHS="${IMAGE_BUILD_TARGET_GOARCHS}" \
    -e IMAGE_WGCF_VERSION="${IMAGE_WGCF_VERSION}" \
    -e IMAGE_WGCF_COMMIT="${IMAGE_WGCF_COMMIT}" \
    -e IMAGE_BUILD_REVISION="${IMAGE_BUILD_REVISION}" \
    --user=root \
    quay.io/buildah/stable:v${IMAGE_BUILDAH_VERSION}@sha256:${IMAGE_BUILDAH_DIGEST} \
    ./build.sh
```

## License

MIT
