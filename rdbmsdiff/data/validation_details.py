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

from dataclasses import dataclass
from enum import Enum
from enum import (
    auto,
    unique,
)
from typing import Tuple


@unique
class ValidationResult(Enum):
    PASSED = auto()
    FAILED = auto()


@dataclass(frozen=True)
class ValidationQuery:
    sql: str
    result_set: str


@dataclass(frozen=True)
class ColumnValidationDetails:
    result: ValidationResult
    validator_description: str
    source_query_details: ValidationQuery
    target_query_details: ValidationQuery


@dataclass(frozen=True)
class TableValidationDetails:
    table_name: str
    column_validations_details: Tuple[ColumnValidationDetails, ...]

    @property
    def result(self) -> ValidationResult:
        for column in self.column_validations_details:
            if column.result is ValidationResult.FAILED:
                return ValidationResult.FAILED
        return ValidationResult.PASSED

    @property
    def overall_validation_count(self) -> int:
        return len(self.column_validations_details)

    @property
    def failed_validation_count(self) -> int:
        result = 0
        for single_details in self.column_validations_details:
            if single_details.result is ValidationResult.FAILED:
                result += 1
        return result
