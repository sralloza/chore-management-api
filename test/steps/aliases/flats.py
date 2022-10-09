from behave import *

from common.alias.flats import create_flat


@given("I create a flat")
def step_impl(context):
    create_flat(context)


@given("I create a flat with a user")
def step_impl(context):
    create_flat(context, user=True)
