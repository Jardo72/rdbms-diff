#
# Copyright 2025 Jaroslav Chmurny
#
# This file is part of RDBMS Diff.
#
# RDBMS Diff is free software licensed under the Apache License,
# Version 2.0 (the "License"); you may not use this file except in
# compliance with the License. You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

from __future__ import annotations
from argparse import ArgumentError
from enum import (
    Enum,
    unique,
)
from importlib.resources import (
    as_file,
    files,
)
from traceback import print_exc

from rich.console import Console
from rich.padding import Padding
from rich.text import Text


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


def _load_banner() -> str:
    resource = files("rdbmsdiff.foundation").joinpath("banner.txt")
    with as_file(resource) as file:
        return file.read_text(encoding="UTF-8")


def print_banner() -> None:
    console = Console(record=False, highlight=False)
    banner = _load_banner()
    console.print(Padding(Text(banner, justify="left", style="bold green"), (1, 2)))


def handle_general_error(e: Exception) -> None:
        if isinstance(e, ArgumentError):
            raise
        print("ERROR!!! Unexpected exception caught:")
        print_exc()
