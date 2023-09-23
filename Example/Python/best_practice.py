"""Best Practice

Python Version: 3.11
"""

from dataclasses import dataclass, asdict
from typing import Optional, assert_never, NewType, Never, Self

# 类型提示

Name = NewType("Name", str)
Size = NewType("Size", int)
Weight = NewType("Weight", float)
Data = NewType("Data", str)


@dataclass
class ParamA:
    name: Name
    size: Size


@dataclass
class ParamB:
    name: Name
    weight: Weight


@dataclass
class Result:
    data: Data


Param = ParamA | ParamB


def functions(param: Param) -> Optional[Result]:
    match param:
        case ParamA(name, size):
            result = Result(Data("Got Param A"))
        case ParamB(name, weight):
            result = Result(Data("Got Param B"))
        case _ as unreachable:
            assert_never(unreachable)

    return result


class MyCls:
    def __init__(self):
        pass

    def fit(self, data: int) -> Self:
        return self


def never_called_func() -> Never:
    raise NotImplementedError("Should not be called")


# TODO: https://kobzol.github.io/rust/python/2023/05/20/writing-python-like-its-rust.html
# 安全互斥锁


if __name__ == "__main__":
    print("========== 1. 类型提示 =============")
    result = functions(ParamA(Name("paramA"), Size(12)))
    if not result is None:
        print(f"Param 序列化: {asdict(result)}")
