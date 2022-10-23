FROM node:16.18.0 as base

RUN npm install -g prisma

# Add package file
COPY package.json ./
COPY package-lock.json ./

# Install deps
RUN npm install

# Copy source
COPY src ./src
COPY prisma ./prisma
COPY tsconfig.json tslint.json /
# COPY openapi.json ./openapi.json

# Build dist
RUN prisma generate && \
    npm run build

# Start production image build
FROM node:16.18.0-slim

# Copy node modules and build directory
COPY --from=base ./node_modules ./node_modules
COPY --from=base /dist /dist

# Copy static files
# COPY src/public dist/src/public

# Expose port 3000
EXPOSE 8080

#  TODO: run prisma migrations
# CMD [ "npm", "run", "start" ]
CMD ["dist/index.js"]
