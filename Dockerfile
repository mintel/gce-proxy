FROM debian:10.3-slim as build

RUN apt-get -y update && \
    apt-get -y install \
      netcat \
      wget

ENV GCE_PROXY_VERSION=1.16 \
    GCE_PROXY_SHA256=6e4df1e2b62e41b3c01818f75dd46a99cb0e9d385c3b6237281251e28cb38432

RUN set -e \
    && wget -q -O /tmp/cloud_sql_proxy https://storage.googleapis.com/cloudsql-proxy/v${GCE_PROXY_VERSION}/cloud_sql_proxy.linux.amd64 \
    && chmod +x /tmp/cloud_sql_proxy \
    && cd /tmp \
    && echo "$GCE_PROXY_SHA256 cloud_sql_proxy" | sha256sum -c

FROM gcr.io/distroless/base

ARG TITLE="gce-proxy"
ARG DESCRIPTION="Custom image for gce-proxy which includes netcat for livenessProbes."
ARG VERSION="1.16"

ARG VENDOR="Mintel Group Ltd."
ARG SOURCE="https://github.com/mintel/gce-proxy"
ARG AUTHORS="Bobby Brockway <bbrockway@mintel.com>"

# These should be passed in at build time
ARG CREATED
ARG REVISION

LABEL org.opencontainers.image.created="$CREATED" \
      org.opencontainers.image.source="$SOURCE" \
      org.opencontainers.image.version="$VERSION" \
      org.opencontainers.image.revision="$REVISION" \
      org.opencontainers.image.vendor="$VENDOR" \
      org.opencontainers.image.title="$TITLE" \
      org.opencontainers.image.description="$DESCRIPTION" \
      org.opencontainers.image.authors="$AUTHORS" \
      org.label-schema.build-date="$CREATED" \
      org.label-schema.vcs-url="$SOURCE" \
      org.label-schema.version="$VERSION" \
      org.label-schema.vcs-ref="$REVISION" \
      org.label-schema.vendor="$VENDOR" \
      org.label-schema.name="$TITLE" \
      org.label-schema.description="$DESCRIPTION"

COPY --from=build /bin/nc /bin/nc

# Add to / to keep in-line with upstream image
COPY --from=build /tmp/cloud_sql_proxy /cloud_sql_proxy
