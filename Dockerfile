# ✅ Use Debian-based Node image (no musl issues)
FROM node:18-bullseye AS base

WORKDIR /usr/src/wpp-server
ENV NODE_ENV=production PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

# Install dependencies
COPY package.json ./
RUN apt-get update && apt-get install -y libvips-dev \
    && npm install --include=optional \
    && npm install sharp --force

# Build stage
FROM base AS build
WORKDIR /usr/src/wpp-server
COPY . .
RUN npm run build

# Final stage
FROM base
WORKDIR /usr/src/wpp-server
COPY --from=build /usr/src/wpp-server /usr/src/wpp-server
EXPOSE 21465
CMD ["node", "dist/server.js"]
