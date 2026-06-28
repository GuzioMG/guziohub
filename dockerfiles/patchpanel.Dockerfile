# Heavily adapted from https://git.shork.ch/docker-images/out-of-your-element
# Couldn't use their image directly as it doesn't support ARM
# Couldn't use their Dockerfile directly as it does the repo-cloning step outside of the build process (they use Forgejo Workflows for that instead) so I had to glue a downloader to the builder.

FROM node:alpine as builder
ENV NODE_ENV=production
WORKDIR /usr/src/app
RUN ["apk", "add", "--no-cache", "python3", "make", "build-base", "git"]
#..., "jq", "curl"]
RUN ["git", "clone", "-b", "mergable-fr-fr", "https://gitdab.com/Guzio/out-of-your-element.git", "."]
#RUN ["git", "fetch", "--all", "--tags"]
#RUN git checkout tags/$(curl -s https://gitdab.com/api/v1/repos/cadence/out-of-your-element/releases?limit=1 | jq -r .[0].tag_name)
RUN ["npm", "install", "."]

FROM node:alpine
WORKDIR /usr/src/app
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app .
CMD ["npm", "run", "start"]