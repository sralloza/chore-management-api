# Chore Management API

API to manage chores in a shared flat.

## Testing

```shell
# Launch all tests
behave

# Launch tests of a specific API
behave -t api.flats

# Launch tests of a specific endpoint
behave -t getChoreTypes

# Launch authorization tests
behave -t authorization
```

## Deploy

Docker images are provided in [dockerhub](https://hub.docker.com/r/sralloza/chore-management-api).

**Note: the database must be mariadb or mysql.**

## Configuration

Configuration is done by setting environment variables.

### Required

- **_ADMIN_API_KEY_**: master administration API key.
- **_APPLICATION_SECRET_**: secret key for the application. Used to sign JWT tokens.

### Optional

- **_REDIS_HOST_**: redis host. Defaults to `localhost`.
- **_REDIS_PORT_**: redis port. Defaults to `6379`.
- **_DATABASE_HOST_**: database host. Defaults to `localhost`.
- **_DATABASE_PORT_**: database port. Defaults to `3306`.
- **_DATABASE_NAME_**: database name. Defaults to `chore-management`.
- **_DATABASE_USERNAME_**: database username. Defaults to `root`.
- **_DATABASE_PASSWORD_**: database password. Defaults to `root`.
- **_RUN_MIGRATIONS_**: run migrations on start. Defaults to `true`, meaning by default migrations are executed on start.

### Optional only for docker

These variables are only used when running the docker image. The docker entrypoint script will manage them.

- **_CREATE_DATABASE_**: if set to true, it will try to create the database each time the container starts.
- **_WAIT_FOR_IT_ADDRESS_**: address to wait for. For example, to wait for a database to be ready, set it to `database:3306`. It currently supports only one address, but in the future it will support multiple addresses separated by commas.
