FROM gliderlabs/alpine

WORKDIR /root

RUN apk-install bash docker git jq python zip

ENV AWS_DEFAULT_REGION=us-west-2

RUN curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip" \
  && unzip awscli-bundle.zip \
  && ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws \
  && rm -rf awscli-bundle \
  && rm awscli-bundle.zip

COPY . /root
