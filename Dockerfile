FROM --platform=$BUILDPLATFORM golang:1.13

ARG RESTIC_VERSION
ARG TARGETPLATFORM
ARG BUILDPLATFORM

# Clone Restic source code
WORKDIR /go/src/github.com/restic/restic
RUN git clone --quiet --depth=1 --branch=${RESTIC_VERSION} https://github.com/restic/restic.git .

# Download dependencies
RUN go mod download

# Get final architecture
# linux/amd64, linux/arm/v7, linux/arm/v6, linux/arm64
RUN export OS=$(echo $TARGETPLATFORM | cut -d "/" -f1) && \
  export ARCH=$(echo $TARGETPLATFORM | cut -d "/" -f2) && \
  export ARM=$(echo $TARGETPLATFORM | cut -d "/" -f3 | sed -e 's/v//') && \
  echo "OS=$OS ARCH=$ARCH ARM=$ARM" && \
  if [ -z "$ARM" ]; then export BUILD_ARGS="--goos $OS --goarch $ARCH"; else export BUILD_ARGS="--goos $OS --goarch $ARCH --goarm $ARM"; fi && \
  echo ${BUILD_ARGS} && \
  go run build.go \
  --verbose \
  --output /restic \
  ${BUILD_ARGS}

FROM --platform=$BUILDPLATFORM scratch

ARG BUILD_DATE

LABEL maintainer="Quentin Lemaire <quentin@lemairepro.fr>"
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=${BUILD_DATE}
LABEL org.label-schema.name="restic"
LABEL org.label-schema.description="Fast, secure, efficient backup program"
LABEL org.label-schema.url="https://github.com/restic/restic"

COPY --from=0 /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=0 /restic /restic

USER 1000:1000
ENTRYPOINT [ "/restic" ]
CMD [ "--help" ]
