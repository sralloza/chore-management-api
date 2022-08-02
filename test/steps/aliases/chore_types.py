from string import ascii_uppercase

from behave import *

from common.utils import *


@given("there is {chore_types:d} chore type")
@given("there are {chore_types:d} chore types")
def step_impl(context, chore_types):
    for i in range(chore_types):
        raw_data = {"id": ascii_uppercase[i], "description": f"description{i+1}"}
        context.execute_steps(
            f"""
            Given I use the admin token
            When I send a request to the Api resource "createChoreType" with body params
            {payload_to_table_format(raw_data)}
            Then the response status code is "200"
            And I clear the token
            """
        )
