# Meal Planner Bot

Successor of the [Meal Planner API](https://github.com/sralloza/meal-planner).

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

### Finished

- choreTypes - createChoreType
- choreTypes - deleteChoreType
- choreTypes - getChoreType
- choreTypes - listChoreTypes
- tenants - createTenant
- tenants - deleteTenant
- tenants - getTenant
- tenants - listTenants
- tenants - recreateTenantToken
- tenants - skipWeek
- weekId - getCurrentWeekId
- weekId - getLastWeekId
- weekId - getNextWeekId

### In progress

- tenants - unSkipWeek
- transfers - acceptTransfer
- transfers - getTransfer
- transfers - listTransfers
- transfers - rejectTransfers
- transfers - startTransfer
- weeklyChores - createWeeklyChores
- weeklyChores - deleteWeeklyChores
- weeklyChores - getWeeklyChores
- weeklyChores - listWeeklyChores

### Ready

- tickets - transferTickets
- tickets - getTicketsByChoreType
- tickets - listTickets

## Deploy

Docker images are provided in [dockerhub](https://hub.docker.com/r/sralloza/chore-management-api).

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
