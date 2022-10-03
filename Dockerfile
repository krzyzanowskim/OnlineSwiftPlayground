# ================================
# Build BE image
# ================================
FROM swift:5.7-jammy AS build-be

# Install OS updates and, if needed, sqlite3
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get -q install -y \
       libsqlite3-dev \
       libcurl4 \
       libxml2 libxml2-dev \
       zlib1g-dev zlib1g \
    && rm -rf /var/lib/apt/lists/*

# Set up a build area
WORKDIR /build

# First just resolve dependencies.
# This creates a cached layer that can be reused
# as long as your Package.swift/Package.resolved
# files do not change.
COPY ./Package.* ./
RUN swift package resolve

COPY ./OnlinePlayground/Package.* ./OnlinePlayground/
RUN swift package --package-path OnlinePlayground resolve

# Copy entire repo into container
COPY . .

# Build everything, with optimizations
RUN swift build -c release -Xswiftc -static-stdlib -Xswiftc -Xclang-linker -Xswiftc -fuse-ld=lld
RUN swift build -c release --package-path OnlinePlayground -Xswiftc -static-stdlib -Xswiftc -Xclang-linker -Xswiftc -fuse-ld=lld

# Switch to the staging area
WORKDIR /staging

# Copy main executable to staging area
RUN cp "$(swift build --package-path /build -c release --show-bin-path)/PlaygroundServer" ./

# Copy resources bundled by SPM to staging area
RUN find -L "$(swift build --package-path /build -c release --show-bin-path)/" -name '*.resources' -exec cp -Ra {} ./ \;


# Copy any resources from the public directory and views directory if the directories exist
# Ensure that by default, neither the directory nor any of its contents are writable.
RUN [ -d /build/Public ] && { mv /build/Public ./Public && chmod -R a-w ./Public; } || true
RUN [ -d /build/Resources ] && { mv /build/Resources ./Resources && chmod -R a-w ./Resources; } || true

WORKDIR /staging/lib

# Copy linked libraries
RUN cp -R "$(swift build --package-path /build/OnlinePlayground -c release --show-bin-path)"/. .

# Get 3rd party dependencies
WORKDIR /vendor
RUN git clone https://github.com/kylef/swiftenv.git .swiftenv


# ================================
# Build FE image
# ================================
FROM node:16 AS build-fe

WORKDIR /build

COPY ./package.* ./

RUN npm install --quiet

COPY . .

RUN npx webpack --display errors-only --output-path /staging


# ================================
# Run image
# ================================
FROM ubuntu:jammy
LABEL maintainer="marcin@krzyzanowskim.com"
LABEL Description="SwiftPlayground.run docker image"

# Make sure all system packages are up to date, and install only essential packages.
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get -q install -y \
      build-essential \
      curl \
      libsqlite3-dev \
      ca-certificates \
      tzdata \
      libxml2 \
      #, import FoundationNetworking -> libcurl4 \
    && rm -r /var/lib/apt/lists/*

# Create a vapor user and group with /app as its home directory
RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app vapor

# Switch to the new home directorysd
WORKDIR /app

# Copy built executable, staged resources and dependencies from builder
COPY --from=build-be --chown=vapor:vapor /staging /app
COPY --from=build-be --chown=vapor:vapor /vendor /app
COPY --from=build-fe --chown=vapor:vapor /staging /app/Public/static/app

# Ensure all further commands run as the vapor user
USER vapor:vapor

# Setup swiftenv environment
ENV PATH "/app/.swiftenv/bin:/app/.swiftenv/shims:$PATH"
ENV SWIFTENV_PLATFORM ubuntu20.04
RUN swiftenv install 5.7
RUN swiftenv install 5.6.3

# Let Docker bind to port 8080
EXPOSE 8080

# Start the Vapor service when the image is run, default to listening on 8080 in production environment
ENTRYPOINT ["./PlaygroundServer"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]
