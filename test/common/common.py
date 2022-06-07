URL = "http://localhost:8080"
VERSIONED_URL_TEMPLATE = URL + "/v{version}"


def assert_not_errors(errors):
    assert not errors, "\n" + "\n".join(errors) + "\n\n"


def get_path_from_res(res):
    return res.request.url.replace(URL, "")


def assert_arrays_equal(expected, actual):
    errors = []
    if len(expected) != len(actual):
        errors.append(f"- Expected {len(expected)} items, got {len(actual)}")

    for i, (e, a) in enumerate(zip(expected, actual)):
        if e != a:
            errors.append(f"- Position {i} not equal: {e} != {a}")
    assert_not_errors(errors)
