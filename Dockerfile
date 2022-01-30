FROM alpine:latest
RUN apk update && \
    apk add --no-cache wget openssh git python3 curl bash which tar gzip ca-certificates gawk gnupg && \
    curl -sSL https://sdk.cloud.google.com | bash && \
    apk add git-secret --update-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted && \
    rm -rf /var/cache/apk/* && \
    wget --quiet https://releases.hashicorp.com/terraform/1.0.2/terraform_1.0.2_linux_amd64.zip && \
    unzip terraform_1.0.2_linux_amd64.zip && \
    mv terraform /usr/bin && \
    rm terraform_1.0.2_linux_amd64.zip
ENV PATH $PATH:/root/google-cloud-sdk/bin