FROM golang:1.9.2-alpine3.6 as builder

ADD . $GOPATH/src/github.com/sylr/alertmanager-splunkbot
WORKDIR $GOPATH/src/github.com/sylr/alertmanager-splunkbot

RUN apk update && apk upgrade && apk add --no-cache git

RUN git fetch --unshallow

RUN uname -a
RUN go version

RUN go get -v ./...
RUN go build -ldflags "-X main.version=$(git describe --dirty --broken)"
RUN go install

# -----------------------------------------------------------------------------

FROM alpine:3.6

WORKDIR /usr/local/bin
RUN apk --no-cache add ca-certificates
RUN apk update && apk upgrade && apk add --no-cache bash curl
COPY --from=builder "/go/bin/alertmanager-splunkbot" .

ENTRYPOINT ["/usr/local/bin/alertmanager-splunkbot"]
