FROM --platform=${BUILDPLATFORM:-linux/amd64} golang:1.23 as builder

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG TARGETOS
ARG TARGETARCH
ARG GIT_TAG
ARG GIT_COMMIT
ARG USERNAME=kutovoys
ARG REPOSITORY_NAME=xray-checker

ENV CGO_ENABLED=0
ENV GO111MODULE=on

WORKDIR /go/src/github.com/${USERNAME}/${REPOSITORY_NAME}

COPY go.mod go.mod
COPY go.sum go.sum
RUN go mod download

COPY .  .

RUN CGO_ENABLED=${CGO_ENABLED} GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
  go build -ldflags="-X main.version=${GIT_TAG} -X main.commit=${GIT_COMMIT}" -a -installsuffix cgo -o /usr/bin/xray-checker .

FROM --platform=${BUILDPLATFORM:-linux/amd64} gcr.io/distroless/static:nonroot

LABEL org.opencontainers.image.source=https://github.com/${USERNAME}/${REPOSITORY_NAME}

WORKDIR /
COPY --from=builder /usr/bin/xray-checker /
USER nonroot:nonroot

ENTRYPOINT ["/xray-checker"]