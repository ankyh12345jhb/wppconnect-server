FROM node:22.20.0 AS base
WORKDIR /usr/src/wpp-server
ENV NODE_ENV=production PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
COPY package.json ./
RUN apt-get update && apt-get install -y \
    libvips-dev \
    chromium \
    && rm -rf /var/lib/apt/lists/*
RUN yarn install --production --pure-lockfile && \
    yarn add sharp --ignore-engines && \
    yarn cache clean

FROM base AS build
WORKDIR /usr/src/wpp-server
COPY . .
RUN yarn install --production=false --pure-lockfile
RUN yarn build

FROM base
WORKDIR /usr/src/wpp-server/
COPY --from=build /usr/src/wpp-server/ /usr/src/wpp-server/
EXPOSE 21465
ENTRYPOINT ["node", "dist/server.js"]
