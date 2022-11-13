from functools import lru_cache
from pathlib import Path

from jsonschema import FormatChecker, ValidationError, validate
from yaml import safe_load


@lru_cache()
def get_openapi():
    root = Path(__file__).parent.parent.parent
    openapi = root / "openapi.yml"
    content = openapi.read_text()
    return safe_load(content)


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
        raise ValueError(f"Operation {operation_id} not found in openapi.yml")
    return operations[0]


def get_current_operation(context):
    operations = [
        k for k in get_operations() if k["operationId"] == context.operation_id
    ]
    if len(operations) != 1:
        raise ValueError(f"Operation {context.operation_id} not found in openapi.yml")
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


def resolve_ref(ref: str):
    data = get_openapi()
    parts = ref.strip("#/").split("/")

    path = data
    for part in parts:
        path = path[part]
    return path


def get_examples(context=None, operation_id=None, code: str | int | None = None):
    if context is None:
        operation = get_operation(operation_id)
    else:
        operation = get_current_operation(context)

    code = str(code or context.res.status_code)

    response = operation["responses"][code]
    if "$ref" in response:
        response = resolve_ref(response["$ref"])

    examples = []
    for example in response["content"]["application/json"]["examples"].values():
        for key, value in example.items():
            if key == "$ref":
                examples.append(resolve_ref(value)["value"])
            elif key == "value":
                examples.append(value)
            elif key == "description":
                continue
            else:
                raise ValueError(f"Unknown example key {key}")
    return examples


def get_operation_schema(context):
    operation = get_current_operation(context)
    code = str(context.res.status_code)
    if code in operation["responses"]:
        schema = operation["responses"][code]
        if "$ref" in schema:
            schema = resolve_ref(schema["$ref"])
        schema = schema["content"]["application/json"]["schema"]
    else:
        raise ValueError(f"No schema found for operation {context.operation_id}")

    if "$ref" in schema:
        schema = resolve_ref(schema["$ref"])

    return dict(schema)


def get_parameters(context=None, operation_id=None):
    operation = (
        get_current_operation(context) if context else get_operation(operation_id)
    )
    parameters = []
    for parameter in operation["parameters"]:
        if "$ref" in parameter:
            parameter = resolve_ref(parameter["$ref"])
            parameters.append(parameter)
        else:
            raise ValueError(f"Unknown parameter {parameter!r}")

    return parameters


def get_request_headers(context=None, operation_id=None):
    parameters = get_parameters(context, operation_id)
    return [x["name"] for x in parameters if x["in"] == "header"]


def get_request_path_parameters(operation_id):
    parameters = get_parameters(operation_id=operation_id)
    return [x["name"] for x in parameters if x["in"] == "path"]


def get_method(operation_id: str):
    operation = get_operation(operation_id)
    return operation["method"].upper()


def get_response_codes(operation_id: str):
    operation = get_operation(operation_id)
    return tuple([int(x) for x in operation["responses"]])


def get_request_body(operation_id: str):
    operation = get_operation(operation_id)
    if "requestBody" in operation:
        return operation["requestBody"]
    return None


def get_operation_path(operation_id: str):
    return get_operation(operation_id)["path"]


def get_security_schemas(operation_id: str):
    operation = get_operation(operation_id)
    if "security" in operation:
        return [list(x.keys())[0] for x in operation["security"]]
    return []


def get_responses(operation_id: str):
    operation = get_operation(operation_id)
    responses = []
    for code, response in operation["responses"].items():
        if "$ref" in response:
            response = resolve_ref(response["$ref"])
        response["status_code"] = code
        responses.append(response)
    return responses
