FROM scratch as downloader
WORKDIR /repo
ADD https://gitdab.com/Guzio/out-of-your-element.git#mergable-fr-fr .
# ADD https://gitdab.com/cadence/out-of-your-element.git .

FROM node:alpine as builder
ENV NODE_ENV=production
WORKDIR /usr/src/app
RUN ["apk", "add", "--no-cache", "python3", "make", "build-base"]
COPY --from=downloader /repo/jsconfig.json ./jsconfig.json
COPY --from=downloader /repo/package-lock.json ./package-lock.json
COPY --from=downloader /repo/package.json ./package.json
RUN ["npm", "ci"]
COPY --from=downloader /repo .
RUN ["npm", "install"]

FROM node:alpine
ENV NODE_ENV=production
WORKDIR /usr/src/app
COPY --from=builder /usr/src/app/jsconfig.json ./jsconfig.json
COPY --from=builder /usr/src/app/package-lock.json ./package-lock.json
COPY --from=builder /usr/src/app/package.json ./package.json
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app .
CMD ["npm", "run", "start"]