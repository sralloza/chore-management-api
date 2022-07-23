from collections import namedtuple

from common.utils import replace_param

ChoreType = namedtuple("ChoreType", "id description")


def get_chore_types(context):
    return [ChoreType(**x) for x in context.get("/chore-types").json()]


def get_chore_types_from_res(context):
    context.execute_steps("Given the response body is a valid json")
    json_data = context.res.json()

    if isinstance(json_data, list):
        return [ChoreType(**x) for x in json_data]
    return [ChoreType(**json_data)]


def get_chore_types_from_feature_table(context):
    if context.table is None:
        return []
    return [create_chore_type_from_row(x) for x in context.table.rows]


def create_chore_type_from_row(row):
    return ChoreType(
        replace_param(row["id"]),
        replace_param(row["description"]),
    )
