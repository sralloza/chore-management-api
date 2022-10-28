# base image
FROM node:18.12.0-slim as base

RUN apt update && \
    apt install curl -y

WORKDIR /data

FROM base as builder

COPY package.json package-lock.json tslint.json tsconfig.json /data/

RUN npm install

COPY src ./src
RUN npx tsc

FROM base

COPY delivery/wait-for-it.sh /data/wait-for-it.sh
COPY delivery/entrypoint.sh /data/entrypoint.sh
RUN chmod +x /data/*.sh

COPY migrations ./migrations
COPY --from=builder /data/package*.json /data/
COPY --from=builder /data/node_modules ./node_modules
COPY --from=builder /data/dist /data/dist

EXPOSE 8080
ENTRYPOINT [ "/data/entrypoint.sh" ]
CMD npm run start
