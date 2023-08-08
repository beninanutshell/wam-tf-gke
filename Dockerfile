FROM alpine:3.18.3
RUN apk update && \
    apk add --no-cache wget openssh git bash gzip ca-certificates gawk gnupg && \
    apk add git-secret --update-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted && \
    wget --quiet https://releases.hashicorp.com/terraform/1.1.4/terraform_1.1.4_linux_amd64.zip && \
    unzip terraform_1.1.4_linux_amd64.zip && \
    mv terraform /usr/bin && \
    rm terraform_1.1.4_linux_amd64.zip $$ \
    rm -rf /var/cache/apk/*