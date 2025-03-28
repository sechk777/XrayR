# Build go
FROM golang:1.24-alpine AS builder
WORKDIR /app
COPY . .
ENV CGO_ENABLED=0
RUN go mod download
RUN go build -v -o XrayR -trimpath -ldflags "-s -w -buildid="

# Release
FROM  alpine
# 安装必要的工具包
RUN  apk --update --no-cache add tzdata ca-certificates \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

COPY --from=builder /app/init.sh /init.sh
RUN mkdir /etc/XrayR/ \
    && chmod +x init.sh
COPY --from=builder /app/XrayR /usr/local/bin
COPY --from=builder /app/release/config /home

ENTRYPOINT ["/init.sh"]