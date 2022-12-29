from behave import given


@given('the header language is set to "{lang}"')
def step_set_lang(context, lang: str):
    if "headers" not in context:
        context.headers = {}
    context.headers["Accept-Language"] = lang
