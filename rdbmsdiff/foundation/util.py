from __future__ import annotations
from enum import Enum, unique


@unique
class Status(Enum):
    OK = 1
    WARNING = 2
    ERROR = 3

    @staticmethod
    def format(status: Status) -> str:
        if status is Status.OK:
            color = "green"
        elif status is Status.WARNING:
            color = "yellow"
        else:
            color = "red"
        return f"[bold][{color}]{status.name}[/{color}][/bold]"


