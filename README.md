# Meal Planner Bot

Successor of the - [Meal Planner API](https://github.com/sralloza/meal-planner).

## Testing

```shell
# Launch all tests
behave

# Launch tests of a specific API
behave -t api.tenants

# Launch tests of a specific endpoint
behave -t getTenant

# Launch sanity tests (most important features)
behave -t sanity

# Launch authorization tests
behave -t authorization
```

## Development

### Endpoints

- [x] choreTypes
  - [x] createChoreType
  - [x] deleteChoreType
  - [x] getChoreType
  - [x] listChoreTypes
- [x] tenants
  - [x] createTenant
  - [x] deleteTenant
  - [x] getTenant
  - [x] listTenants
  - [x] recreateTenantToken
  - [x] skipWeek
  - [x] unSkipWeek
- [x] transfers
  - [x] acceptTransfer
  - [x] getTransfer
  - [x] listTransfers
  - [x] rejectTransfer
  - [x] startTransfer
- [x] weekId
  - [x] getCurrentWeekId
  - [x] getLastWeekId
  - [x] getNextWeekId
- [x] weeklyChores
  - [x] completeTask
  - [x] createWeeklyChores
  - [x] deleteWeeklyChores
  - [x] getWeeklyChores
  - [x] listWeeklyChores
- [x] tickets
  - [x] listTickets

### Other tasks

- [ ] Add pagination in all `list` endpoints
- [ ] Add prometheus metrics
- [ ] Add redoc documentation
- [x] Update `sanity` tag
- [ ] Fix timing tests in CI

## Deploy

Docker images are provided in - [dockerhub](https://hub.docker.com/r/sralloza/chore-management-api).

## Configuration

Configuration is done by setting environment variables.

### Required

- **_ADMIN_TOKEN_**: only token with admin access.

### Optional

- **_MYSQL_HOST_**: host where the database is. Defaults to `localhost`.
- **_MYSQL_PORT_**: port where the database listens to. Defaults to `3306`.
- **_MYSQL_DATABASE_**: database name to use. Defaults to `chore-management`.
- **_MYSQL_USER_**: user to access the database. Defaults to `root`.
- **_MYSQL_PASSWORD_**: password to access the database. Defaults to `root`.
- **_LOG_LEVEL_**: general level of logs. Defaults to `INFO`.
- **_SPRING_WEB_LOG_LEVEL_**: spring logger level. Defaults to `DEBUG`.
- **_HIBERNATE_LOG_LEVEL_**: hibernate logger level. Defaults to `INFO`.
