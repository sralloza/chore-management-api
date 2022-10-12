from pathlib import Path

from jsonschema import FormatChecker, ValidationError, validate
from ruamel.yaml import YAML


def get_openapi():
    root = Path(__file__).parent.parent.parent
    openapi = root / "src/main/resources/openapi.yaml"
    content = openapi.read_text()
    return YAML(typ="safe").load(content)


def get_defined_schemas():
    data = get_openapi()

    schemas = {}
    for schema_name, schema in data["components"]["schemas"].items():
        schemas[schema_name] = schema

    return schemas


def get_operations():
    operations = []
    data = get_openapi()
    for path in data["paths"]:
        for method in data["paths"][path]:
            operation = data["paths"][path][method]
            operation["path"] = path
            operation["method"] = method
            operations.append(operation)
    return operations


def get_operation(operation_id):
    operations = [k for k in get_operations() if k["operationId"] == operation_id]
    if len(operations) != 1:
        raise ValueError(f"Operation {operation_id} not found in openapi.yaml")
    return operations[0]


def get_current_operation(context):
    operations = [
        k for k in get_operations() if k["operationId"] == context.operation_id
    ]
    if len(operations) != 1:
        raise ValueError(f"Operation {context.operation_id} not found in openapi.yaml")
    return operations[0]


def validate_response(api_response, json_schema, resolver):
    try:
        validate(
            api_response,
            json_schema,
            resolver=resolver,
            format_checker=FormatChecker(),
        )
    except ValidationError as exc:
        msg = f"- Json Schema ValidationError: {exc.message}"
        assert False, msg
