FROM ibmcom/swift-ubuntu:latest
LABEL maintainer="marcin@krzyzanowskim.com"
LABEL Description="SwiftPlayground.run docker image"
WORKDIR /swiftplayground

# We can replace this port with what the user wants
EXPOSE 8080

# Default user if not provided
ARG bx_dev_user=root
ARG bx_dev_userid=1000

# Install system level packages
# RUN apt-get update && apt-get dist-upgrade -y

# Add utils files
ADD https://raw.githubusercontent.com/IBM-Swift/swift-ubuntu-docker/master/utils/run-utils.sh /swift-utils/run-utils.sh
ADD https://raw.githubusercontent.com/IBM-Swift/swift-ubuntu-docker/master/utils/common-utils.sh /swift-utils/common-utils.sh
RUN chmod -R 555 /swift-utils

# Create user if not root
RUN if [ $bx_dev_user != "root" ]; then useradd -ms /bin/bash -u $bx_dev_userid $bx_dev_user; fi

# Bundle application source & binaries
COPY . /swiftplayground

# Command to start Swift application
CMD ["swift", "build", "-c", "release", "--disable-prefetching"]
CMD ["swift", "run", "-c", "release", "--disable-prefetching"]
