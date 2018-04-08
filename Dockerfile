FROM ibmcom/swift-ubuntu:4.0.3
LABEL maintainer="marcin@krzyzanowskim.com"
LABEL Description="SwiftPlayground.run docker image"
WORKDIR /swiftplayground

# We can replace this port with what the user wants
EXPOSE 8080

# Default user if not provided
ARG bx_dev_user=root
ARG bx_dev_userid=1000

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
RUN apt-get -qq -y install libz-dev curl

# Bootstrap
RUN ./bootstrap.sh

# Command to start Swift application
RUN Toolchains/swift-4.0.3-RELEASE.xctoolchain/usr/bin/swift package reset
RUN Toolchains/swift-4.0.3-RELEASE.xctoolchain/usr/bin/swift package clean
RUN Toolchains/swift-4.1-RELEASE.xctoolchain/usr/bin/swift build --target OnlinePlayground -c release

CMD Toolchains/swift-4.0.3-RELEASE.xctoolchain/usr/bin/swift run -c release