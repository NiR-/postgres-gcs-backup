FROM postgres:9.6.2-alpine as base

RUN apk add --no-cache \
      ca-certificates \
      python \
      wget \
    && \
    wget -O /tmp/gcloud-sdk.tar.gz https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-220.0.0-linux-x86_64.tar.gz && \
    tar zxvf /tmp/gcloud-sdk.tar.gz && \
    /google-cloud-sdk/install.sh \
      --usage-reporting false \
      --quiet \
    && \
    ln -s /google-cloud-sdk/bin/gcloud /usr/bin/gcloud && \
    ln -s /google-cloud-sdk/bin/gsutil /usr/bin/gsutil && \
    apk del wget

############

FROM base as dump

COPY ./backup-to-gcs /usr/sbin/backup-to-gcs

ARG IMAGE_VERSION
ENV IMAGE_VERSION ${IMAGE_VERSION}

CMD ["backup-to-gcs"]

############

FROM base as restore

COPY ./restore-from-gcs /usr/sbin/restore-from-gcs

ARG IMAGE_VERSION
ENV IMAGE_VERSION ${IMAGE_VERSION}

ENTRYPOINT ["restore-from-gcs"]
