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

from rdbmsdiff.foundation import DBTable, Status

from .validation_details import ColumnValidationDetails, TableValidationDetails, ValidationResult


@dataclass(frozen=True, slots=True)
class Statistics:
    overall_table_count: int
    failed_table_count: int
    overall_validation_count: int
    failed_validation_count: int


class _Statistics:

    def __init__(self) -> None:
        self._overall_table_count = 0
        self._failed_table_count = 0
        self._overall_validation_count = 0
        self._failed_validation_count = 0

    def add_validation_details(self, details: TableValidationDetails) -> None:
        self._overall_table_count += 1
        if details.result is ValidationResult.FAILED:
            self._failed_table_count += 1
        self._overall_validation_count += details.overall_validation_count
        self._failed_validation_count += details.failed_validation_count

    def add_missing_table(self) -> None:
        self._overall_table_count += 1
        self._failed_table_count += 1

    def get_snapshot(self) -> Statistics:
        return Statistics(
            overall_table_count=self._overall_table_count,
            failed_table_count=self._failed_table_count,
            overall_validation_count=self._overall_validation_count,
            failed_validation_count=self._failed_validation_count,
        )


class Report:

    def __init__(self, filename: str) -> None:
        self._file = open(filename, "w")
        self._statistics = _Statistics()

    def _write_table_header(self, details: TableValidationDetails) -> None:
        self._file.write(f"{90 * '='}\n")
        self._file.write(f"= Table:  {details.table_name}\n")
        self._file.write(f"= Status: {details.result.name} ({details.failed_validation_count} of {details.overall_validation_count} validations failed)\n")
        self._file.write(f"{90 * '='}\n")
        self._file.write("\n")

    def _write_column_validation_details(self, details: ColumnValidationDetails) -> None:
        self._file.write(f"{80 * '-'}\n")
        self._file.write(f"- {details.validator_description}\n")
        self._file.write(f"{80 * '-'}\n")
        self._file.write(f"Status: {details.result.name}\n\n")
        self._file.write("Source DB\n")
        self._file.write(f"SQL: {details.source_query_details.sql}\n")
        self._file.write("Result-set:\n")
        self._file.write(details.source_query_details.result_set)
        self._file.write("\n\n")
        self._file.write("Target DB\n")
        self._file.write(f"SQL: {details.target_query_details.sql}\n")
        self._file.write("Result-set:\n")
        self._file.write(details.target_query_details.result_set)
        self._file.write("\n\n")

    def add_missing_table(self, table: DBTable) -> None:
        self._statistics.add_missing_table()
        self._file.write(f"{90 * '='}\n")
        self._file.write(f"= Table:  {table.name}\n")
        self._file.write(f"= Status: {Status.ERROR.name} (table missing in the target database)\n")
        self._file.write(f"{90 * '='}\n")
        self._file.write("\n")
        self._file.flush()

    def add_validation_details(self, table_details: TableValidationDetails) -> None:
        self._statistics.add_validation_details(table_details)
        self._write_table_header(table_details)
        for column_details in table_details.column_validations_details:
            self._write_column_validation_details(column_details)
        self._file.flush()

    def get_statistics(self) -> Statistics:
        return self._statistics.get_snapshot()

    def close(self) -> None:
        self._file.close()
