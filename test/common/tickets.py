from common.utils import toolium_replace


def parse_tickets_res_table_str(res, sort_key=lambda x: x):
    step_1 = {}
    for line in res.json():
        for tenant, tickets in line["tickets_by_user_id"].items():
            if tenant not in step_1:
                step_1[tenant] = {}

            step_1[tenant][line["id"]] = tickets

    data = []
    for tenant, ticket_map in step_1.items():
        result = {}
        result["user_id"] = tenant
        for _id, tickets in ticket_map.items():
            result[_id] = tickets
        data.append(result)

    data.sort(key=sort_key)
    return data


def parse_tickets_table(
    table, *, infer_param_type=True, attrs: list[str] | None = None
):
    if not table:
        return []

    result = []
    for row in table:
        parsed_row = dict(row.as_dict())
        new_row = {}
        for idx, key in enumerate(parsed_row):
            new_key = key
            if idx:
                new_key = f"ct-{key.lower()}"
            if attrs is not None and key not in attrs:
                continue
            new_row[new_key] = toolium_replace(
                parsed_row[key], infer_param_type=infer_param_type
            )
        result.append(new_row)
    return result
