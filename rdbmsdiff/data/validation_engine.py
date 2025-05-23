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

from typing import Tuple

from rich.console import Console

from rdbmsdiff.foundation import Configuration, DBSchema, DBTable, Stopwatch

from .abstract_validator import AbstractValidator
from .boolean_validator import BooleanValidator
from .date_time_validator import DateTimeValidator
from .null_value_count_validator import NullValueCheckType, NullValueCountValidator
from .numeric_validator import NumericValidator
from .record_validator import RecordValidator
from .report import Report
from .validation_details import TableValidationDetails
from .varchar_length_validator import VarcharLengthValidator
from .varchar_value_validator import VarcharValueValidator


class ValidationEngine:

    def __init__(self, config: Configuration, source_db_meta_data: DBSchema, target_db_meta_data: DBSchema, report: Report):
        self._config = config
        self._source_db_meta_data = source_db_meta_data
        self._target_db_meta_data = target_db_meta_data
        self._report = report
        self._console = Console(record=False, highlight=False)

    def _create_validators(self, table: DBTable) -> Tuple[AbstractValidator, ...]:
        result = []
        for column in table.columns:
            if column.is_numeric:
                result.append(NumericValidator(self._config, table, column))
            elif column.is_string:
                result.append(VarcharLengthValidator(self._config, table, column))
                result.append(VarcharValueValidator(self._config, table, column))
            elif column.is_boolean:
                result.append(BooleanValidator(self._config, table, column))
            elif column.is_date_time:
                result.append(DateTimeValidator(self._config, table, column))
            if column.nullable:
                result.append(NullValueCountValidator(self._config, table, column, NullValueCheckType.IS_NULL))
                result.append(NullValueCountValidator(self._config, table, column, NullValueCheckType.IS_NOT_NULL))
        result.append(RecordValidator(self._config, table))
        return tuple(result)

    def _validate_single_table(self, table: DBTable) -> TableValidationDetails:
        validators = self._create_validators(table)
        details = []
        for validator in validators:
            column_validation_details = validator.validate()
            details.append(column_validation_details)
        return TableValidationDetails(table.name, tuple(details))

    def validate(self) -> None:
        self._console.print()
        self._console.print("[cyan]Going to compare tables...[/cyan]")
        table_count = len(self._source_db_meta_data.tables)
        overall_stopwatch = Stopwatch.start()
        with self._console.status(f"Comparing tables..."):
            for index, table in enumerate(self._source_db_meta_data.tables):
                if not self._target_db_meta_data.has_table(table):
                    self._report.add_missing_table(table)
                    self._console.print(f"{table.name} ({index + 1}/{table_count}) missing in target database")
                    continue
                stopwatch = Stopwatch.start()
                details = self._validate_single_table(table)
                elapsed_time = stopwatch.elapsed_time_as_str()
                self._report.add_validation_details(details)
                self._console.print(f"{table.name} ({index + 1}/{table_count}) compared (totally {details.overall_validation_count} comparisons, duration = {elapsed_time})")
        overall_elapsed_time = overall_stopwatch.elapsed_time_as_str()
        print(f"Overall duration = {overall_elapsed_time}")
