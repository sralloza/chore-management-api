def reset_databases(context):
    remove_all(context, "/tenants", "telegram_id")
    remove_all(context, "/chore-types", "id")
    remove_all(context, "/weekly-chores", "week_id")


def get_ids_from_response(res, key):
    return [x[key] for x in res.json()]


def remove_all(context, endpoint, key_field):
    context.res = context.get(endpoint)
    context.execute_steps('Given the response status code is "200"')

    ids = get_ids_from_response(context.res, key_field)
    for resource_id in ids:
        context.res = context.delete(f"{endpoint}/{resource_id}")
        context.execute_steps('Given the HTTP status code should be in "200,204"')

    context.res = None
