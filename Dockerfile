# base image
FROM node:18.12.0-slim as base

WORKDIR /data

RUN apt-get -qy update && apt-get -qy install openssl

FROM base as builder

COPY package.json package-lock.json tslint.json tsconfig.json /data/

COPY prisma ./prisma

RUN npm install && \
    npm install @prisma/client

COPY src ./src

RUN npx prisma generate --schema ./prisma/schema.prisma
RUN npx tsc

FROM base

COPY --from=builder /data/package*.json /data/
COPY --from=builder /data/node_modules ./node_modules
COPY --from=builder /data/dist /data/dist

EXPOSE 3000
CMD npm run start
