# Chore Management API

API to manage chores in a shared flat.

## Testing

```shell
# Launch all tests
behave

# Launch tests of a specific API
behave -t api.flats

# Launch tests of a specific endpoint
behave -t getTenant

# Launch sanity tests (most important features)
behave -t sanity

# Launch authorization tests
behave -t authorization
```

## Pending features

## Deploy

Docker images are provided in [dockerhub](https://hub.docker.com/r/sralloza/chore-management-api).

## Configuration

Configuration is done by setting environment variables.

### Required

<!-- TODO: update -->

- **_ADMIN_TOKEN_**: only token with admin access.

### Optional

<!-- TODO: update -->

- **_MYSQL_HOST_**: host where the database is. Defaults to `localhost`.
- **_MYSQL_PORT_**: port where the database listens to. Defaults to `3306`.
- **_MYSQL_DATABASE_**: database name to use. Defaults to `chore-management`.
- **_MYSQL_USER_**: user to access the database. Defaults to `root`.
- **_MYSQL_PASSWORD_**: password to access the database. Defaults to `root`.
- **_LOG_LEVEL_**: general level of logs. Defaults to `INFO`.
- **_SPRING_WEB_LOG_LEVEL_**: spring logger level. Defaults to `DEBUG`.
- **_HIBERNATE_LOG_LEVEL_**: hibernate logger level. Defaults to `INFO`.
