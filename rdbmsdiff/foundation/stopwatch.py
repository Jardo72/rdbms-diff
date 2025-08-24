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
from time import perf_counter


class Stopwatch:
    """
    Simple stopwatch used to measure the duration of a search. This class is not supposed to be
    directly instantiated by other classes. Instead, the static start() method is to be used.
    """

    def __init__(self) -> None:
        self._start_time = perf_counter()

    @staticmethod
    def start() -> Stopwatch:
        return Stopwatch()

    def elapsed_time_as_str(self) -> str:
        duration_sec = perf_counter() - self._start_time
        duration_sec = round(duration_sec)
        hours, remainder = divmod(duration_sec, 3600)
        minutes, seconds = divmod(remainder, 60)
        return f"{int(hours):02}:{int(minutes):02}:{int(seconds):02}"
