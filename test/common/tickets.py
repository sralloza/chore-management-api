def parse_tickets_res_table_str(res, sort_key=lambda x: x):
    step_1 = {}
    for line in res.json():
        for tenant, tickets in line["tickets_by_tenant"].items():
            if tenant not in step_1:
                step_1[tenant] = {}

            step_1[tenant][line["id"]] = tickets

    data = []
    for tenant, ticket_map in step_1.items():
        result = {}
        result["tenant"] = tenant
        for _id, tickets in ticket_map.items():
            result[_id] = tickets
        data.append(result)

    data.sort(key=sort_key)
    return data
