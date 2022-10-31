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

## Pending features

## Deploy

Docker images are provided in [dockerhub](https://hub.docker.com/r/sralloza/chore-management-api).

**Note: the database must be mariadb or mysql.**

## Configuration

Configuration is done by setting environment variables.

### Required

- **_ADMIN_TOKEN_**: only token with admin access.
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
- **_DISABLE_MIGRATIONS_**: disable migrations on start. Defaults to `false`, meaning by default migrations are executed on start.
