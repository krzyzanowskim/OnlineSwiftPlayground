FROM ibmcom/swift-ubuntu:5.0
LABEL maintainer="marcin@krzyzanowskim.com"
LABEL Description="SwiftPlayground.run docker image"
WORKDIR /swiftplayground

# We can replace this port with what the user wants
EXPOSE 8080

# Default user if not provided
ARG bx_dev_user=root
ARG bx_dev_userid=1000

SHELL ["/bin/bash", "-c"]

# Install system level packages
RUN apt-get update

# Add utils files
ADD https://raw.githubusercontent.com/IBM-Swift/swift-ubuntu-docker/master/utils/run-utils.sh /swift-utils/run-utils.sh
ADD https://raw.githubusercontent.com/IBM-Swift/swift-ubuntu-docker/master/utils/common-utils.sh /swift-utils/common-utils.sh
RUN chmod -R 555 /swift-utils

# Create user if not root
RUN if [ $bx_dev_user != "root" ]; then useradd -ms /bin/bash -u $bx_dev_userid $bx_dev_user; fi

# Bundle application source & binaries
COPY . /swiftplayground

# Install dependencies
RUN apt-get -qq -y install libz-dev curl build-essential libssl-dev

# NVM
ENV NODE_VERSION 8.9.3
ENV NVM_DIR /usr/local/nvm
RUN mkdir /usr/local/nvm

RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash

# install node and npm
RUN source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH:node_modules/.bin

# Bootstrap
RUN ./bootstrap.sh

# Command to start Swift application
# CMD export PATH="$PATH:node_modules/.bin"
# CMD export NVM_DIR="$HOME/.nvm"
# CMD $NVM_DIR/nvm.sh
CMD Toolchains/swift-5.0-RELEASE.xctoolchain/usr/bin/swift run -c release --static-swift-stdlib --build-path .build/swift-5.0-RELEASE