# Base image
FROM node:22-slim

WORKDIR /metrics

ARG TARGETARCH

# Setup
RUN apt-get update \
  # Install latest chrome dev package, fonts to support major charsets and skip chromium download on puppeteer install
  # Based on https://github.com/GoogleChrome/puppeteer/blob/master/docs/troubleshooting.md#running-puppeteer-in-docker
  && apt-get install -y --no-install-recommends wget ca-certificates libgconf-2-4 \
     chromium fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf libxss1 libx11-xcb1 libxtst6 lsb-release \
     # Install deno
     curl unzip \
     # Install ruby to support github licensed gem
     ruby-full git g++ make cmake pkg-config libssl-dev \
     # Install python for node-gyp
     python3 \
  && rm -rf /var/lib/apt/lists/*

# Install deno for miscellaneous scripts
RUN curl -fsSL https://deno.land/x/install/install.sh | DENO_INSTALL=/usr/local sh

RUN gem install licensed

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD="true"
ENV PUPPETEER_EXECUTABLE_PATH="/usr/bin/chromium"

RUN npm i -g npm
COPY package*.json .
RUN npm ci --no-audit

COPY . .
RUN npm run build

ENTRYPOINT ["npm", "start"]
