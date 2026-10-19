FROM scratch AS downloader
WORKDIR /repo
ADD https://gitdab.com/Guzio/out-of-your-element.git#guzio .
# ADD https://gitdab.com/cadence/out-of-your-element.git .

FROM node:26.10.0-alpine AS builder
ENV NODE_ENV=production
WORKDIR /usr/src/app
RUN ["npm", "install", "-g", "npm@12.2.0"]
RUN ["apk", "add", "--no-cache", "python3", "make", "build-base"]
COPY --from=downloader /repo/jsconfig.json ./jsconfig.json
COPY --from=downloader /repo/package-lock.json ./package-lock.json
COPY --from=downloader /repo/package.json ./package.json
RUN ["npm", "ci"]
COPY --from=downloader /repo .
RUN ["npm", "install"]

FROM node:26.10.0-alpine
ENV NODE_ENV=production
WORKDIR /usr/src/app
RUN ["npm", "install", "-g", "npm@12.2.0"]
COPY --from=builder /usr/src/app/jsconfig.json ./jsconfig.json
COPY --from=builder /usr/src/app/package-lock.json ./package-lock.json
COPY --from=builder /usr/src/app/package.json ./package.json
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app .
CMD ["npm", "run", "start"]