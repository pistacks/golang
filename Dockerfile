FROM pistacks/alpine:3.10.1

# https://hub.docker.com/_/golang
RUN apk add --no-cache ca-certificates
RUN [ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf

ENV GOLANG_VERSION 1.12.9

RUN set -eux; \
	apk add --no-cache --virtual .build-deps \
	bash gcc musl-dev openssl go \
	; \
	export \
	GOROOT_BOOTSTRAP="$(go env GOROOT)" \
	GOOS="$(go env GOOS)" \
	GOARCH="$(go env GOARCH)" \
	GOHOSTOS="$(go env GOHOSTOS)" \
	GOHOSTARCH="$(go env GOHOSTARCH)" \
	; \
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		armhf) export GOARM='6' ;; \
		armv7) export GOARM='7' ;; \
	esac; \
	\
	wget -O go.tgz "https://golang.org/dl/go$GOLANG_VERSION.src.tar.gz"; \
	#echo '5032095fd3f641cafcce164f551e5ae873785ce7b07ca7c143aecd18f7ba4076 *go.tgz' | sha256sum -c -; \
	tar -C /usr/local -xzf go.tgz; \
	rm go.tgz; cd /usr/local/go/src; ./make.bash; \
	\
	rm -rf /usr/local/go/pkg/bootstrap /usr/local/go/pkg/obj \
	; \
	apk del .build-deps; \
	\
	export PATH="/usr/local/go/bin:$PATH"; \
	go version

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
WORKDIR $GOPATH
