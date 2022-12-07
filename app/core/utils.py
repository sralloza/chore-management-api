from collections import deque
from itertools import cycle
from typing import TypeVar

T = TypeVar("T")


def expand_array(array: list[T], length: int) -> list[T]:
    output = []
    for element in cycle(array):
        output.append(element)
        if len(output) == length:
            break
    return output


def rotate_array(array: list[T], rotation: int) -> list[T]:
    arr = deque(array)
    arr.rotate(-rotation)
    return list(arr)
