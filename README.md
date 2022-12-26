# Chore Management API

API to manage chores in a shared flat.

## Development

The API is written in python using FastAPI. The first implementation was written in node.js using express. The incomplete node.js version can be found in the commit fa0e9bf7ec4d0b8fa9e7cd10117684551b2afb21.

### Testing

#### Run all tests

The `run-tests.sh` script will start all containers, run the tests and stop the containers. With the flag `--keep-up=true` it will keep the containers up until CTRL-C is pressed.

#### Run some tests

Note that you must have the containers up and running before running the tests (`docker-compose up -d`).

```shell
# Launch all tests
behave

# Launch tests of a specific API
behave -t api.chore-types

# Launch tests of a specific endpoint
behave -t getChoreTypes

# Launch authorization tests
behave -t authorization

# Launch other common tests
behave -t common
```

## Deploy

Docker images are provided in [dockerhub](https://hub.docker.com/r/sralloza/chore-management-api).

**Note: the database must be mariadb or mysql.**

### Configuration

Configuration is done by setting environment variables.

#### Required

- **_ADMIN_API_KEY_**: master administration API key.
- **_APPLICATION_SECRET_**: secret key for the application. Used to sign JWT tokens.

#### Optional

- **_DATABASE_HOST_**: database host. Defaults to `localhost`.
- **_DATABASE_NAME_**: database name. Defaults to `chore-management`.
- **_DATABASE_PASSWORD_**: database password. Defaults to `root`.
- **_DATABASE_PORT_**: database port. Defaults to `3306`.
- **_DATABASE_USERNAME_**: database username. Defaults to `root`.
- **_ENABLE_DB_CLEANUP_**: when set to `true`, the scheduler will be enabled and will run periodically some cleanup database tasks. Defaults to `true`.
- **_IS_PRODUCTION_**: when set to `true`, the application will run in production mode (for example, documentation will not be available). Defaults to `true`.
- **_REDIS_HOST_**: redis host. Defaults to `localhost`.
- **_REDIS_PORT_**: redis port. Defaults to `6379`.

#### Optional only for docker

These variables are only used when running the docker image. The docker entrypoint script will manage them.

- **_CREATE_DATABASE_**: if set to `true`, it will try to create the database each time the container starts.
- **_RUN_MIGRATIONS_**: run migrations on start. Defaults to `true`, meaning by default migrations are executed on start.
- **_WAIT_FOR_IT_ADDRESS_**: comma separated addresses to wait for. For example, to wait for a database to be ready, set it to `database:3306`.
