FROM alpine:latest

RUN apk add --no-cache jq curl docker

COPY bootstrap.sh /app/bootstrap.sh

ENTRYPOINT ["/bin/sh", "-c", "chmod +x /app/bootstrap.sh && sleep 5 && /app/bootstrap.sh"]