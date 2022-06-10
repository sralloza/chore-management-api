def reset_databases(context):
    delete_all(context, "/chore-types", "id")
    delete_all(context, "/tenants", "tenant_id")
    delete_all(context, "/transfers", "id")
    delete_all(context, "/weekly-chores", "week_id")


def get_ids_from_response(res, key):
    try:
        return [x[key] for x in res.json()]
    except KeyError:
        raise ValueError(f"Response does not contain key: {key}\n>>> {res.text}")


def delete_all(context, endpoint, key_field):
    context.res = context.get(endpoint, silenced=True)
    context.execute_steps('Then the response status code is "200"')

    ids = get_ids_from_response(context.res, key_field)
    for resource_id in ids:
        context.res = context.delete(f"{endpoint}/{resource_id}", silenced=True)
        context.execute_steps('Then the HTTP status code should be in "200,204"')

    context.res = None
