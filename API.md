API to manage the chores with the flatmates in a shared flat.

# Concepts

- **User**: Each person living in the same flat, a flatmate.
- **Chore Type**: A defined chore that needs to be executed weekly in the flat. Each chore type will be assigned weekly to a different flatmate.
- **Weekly chores**: Chores grouped by week.
- **Week ID**: Weeks are identified by the year and the week number, like `2022.03` (the third week of 2022).
- **Ticket**: Number of chores of a specific type that the user is owed. For more info, read the [tickets system](#section/Concepts/Tickets-system) section.

# Tickets system

This API supports chore transfers. When a user transfers a chore to other user, a ticket also is transferred. A ticket is like a currency, +1 tickets means that the user is owed a chore (in the future another user will complete his chore), and -1 tickets means that the user owns a chore (in the future he will complete another user's chore).

Diferent chore types are considered non equivalent, so a ticket of (the chore type) X can not be compensated with a ticket of type Y.

# Chore Assignements

You can assign weekly chores using the [createWeeklyChores](#tag/Weekly-Chores/operation/createWeeklyChores) endpoint.

## Examples

### Normal chore assignments, same number of users and chores

Here is an example of the normal chore creation, with 3 users and 3 chore types.

| Week | Chore A | Chore B | Chore C |
| ---- | ------- | ------- | ------- |
| 1    | User 1  | User 2  | User 3  |
| 2    | User 2  | User 3  | User 1  |
| 3    | User 3  | User 1  | User 2  |

### More chores than users

**What happens if there are more chores than users?** Some users will have to complete more than one task in the same week.

| Week | Chore A | Chore B | Chore C | Chore D |
| ---- | ------- | ------- | ------- | ------- |
| 1    | User 1  | User 2  | User 3  | User 1  |
| 2    | User 2  | User 3  | User 1  | User 2  |
| 3    | User 3  | User 1  | User 2  | User 3  |
| 4    | User 1  | User 2  | User 3  | User 1  |

### More users than chores

**What happens if there are more users than chores?** Some users will have no chores some weeks.

| Week | Chore A | Chore B |
| ---- | ------- | ------- |
| 1    | User 1  | User 2  |
| 2    | User 3  | User 1  |
| 3    | User 2  | User 3  |
| 4    | User 1  | User 2  |

## How are chores assigned the first time

The best explanation is an example.

- Users: 501, 293, 381
- Chore types: garden, kitchen and dishes

Sorting the users and chore types:

- Users: 293, 381, 501
- Chore types: dishes, garden, kitchen

So, these will be the default chore assignments:

| Week | dishes | garden | kitchen |
| ---- | ------ | ------ | ------- |
| 1    | 293    | 381    | 501     |
| 2    | 381    | 501    | 293     |
| 3    | 501    | 293    | 381     |

If you want to assign the first time dishes to the user 501, garden to the user 293 and kitchen to the user 281, you will have to use the [editSystemSettings](#tag/System/operation/editSystemSettings) operation and send the `assignment_order` parameter set to `["501", "293", "381"]` (the assignments of the first week sorted alphabetically by the chore ID).

The next weeks the chores will rotate. To ensure the chores will be assigned with the order you want, you can use the `dry_run` parameter in the [createWeeklyChores](#tag/Weekly-Chores/operation/createWeeklyChores) operation. This will return the chore assignments without actually creating them. If you detect the rotation is not correct, you can use the [editSystemSettings](#tag/System/operation/editSystemSettings) operation to set the rotation.

## Skip week

There are occasions when user would want to skip a week. For example, when a user is on vacation. In this case, the user must tell the API to remove himself from the pool when the chores are assigned. This can be done by using the [skipWeek](#tag/Skip-Chores/operation/skipWeek) operation.

If a user has wrongly skipped a week, he can undo it by using the [undoSkipWeek](#tag/Skip-Chores/operation/undoSkipWeek) operation.

## Other considerations

When a user is created o deleted, the field [`settings.assignments_order`](#tag/System/operation/getSystemSettings) are reset. This means that if you have a custom `settings.assignments_order` and you create and delete a user, the `settings.assignments_order` will be reset to its default value.

# Internationalization

This API supports error message internationalization only in user-scoped endpoints (those that need a user API key). The language is selected by the `Accept-Language` header. If the header is not present, the default language is English. The supported languages are: english (en) and spanish (es).

**Disclaimer**: Only the common errors are translated. The validation errors (status code 422) are not translated.

**Warning**: If the language is not supported or is invalid, the API will return an error in the default language.

# Authorization

Access is controlled with API key based authorization. There are 3 types of API keys with different auth levels. Each one of them contains the same permissions as the ones below and more specific permissions.

1. **Admin API key** (_AdminApiKey_): there is only one. It has permission to do anything, from creating a new flat to mark a chore as completed.
2. **Flat API key** (_FlatAdminApiKey_): there is one for each flat. It has permission to manage the flat assigned and the users assigned to the flat.
3. **User API key** (_UserApiKey_): there is one for each user. It has permission to act in name of the user, like transfering chores or completing chores.
