FROM python:3.9-alpine

# Set image labels
LABEL maintainer="mike@cumulustech.us"

# Set build args with defaults
ARG CDK_VERSION=1.86.0

# Setup
RUN mkdir /proj
WORKDIR /proj
RUN apk -U --no-cache add \
    bash \
    git \
    curl \
    nodejs \
    npm &&\
    rm -rf /var/cache/apk/*

# Install essential Python packages
RUN pip install beautifulsoup4 requests 

# Query PyPI registry for all installable CDK modules
COPY list-cdk-packages.py .
RUN CDK_PACKAGES=`./list-cdk-packages.py ${CDK_VERSION}` && pip install `echo $CDK_PACKAGES`

# AWS CDK, AWS SDK, and Matt's CDK SSO Plugin https://www.npmjs.com/package/cdk-cross-account-plugin
RUN npm i -g aws-cdk@${CDK_VERSION} aws-sdk cdk-cross-account-plugin 

# Install additional Python packages
# (this is positioned here to take advantage of layer caching)
RUN pip install Jinja2 stringcase

# Set default run command
CMD ["/bin/bash"]