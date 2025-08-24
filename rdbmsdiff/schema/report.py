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

from json import dump
from typing import (
    Any,
    Dict,
    Sequence,
)

from rich.console import Console

from .diff import (
    DBColumnDiff,
    DBSchemaDiff,
    DBTableDiff,
)


def _generate_column_diff(column_diff: DBColumnDiff) -> Dict[str, Any]:
    return {
        "name": column_diff.name,
        "source_data_type": str(column_diff.source_data_type),
        "target_data_type": str(column_diff.target_data_type),
    }


def _generate_tables_with_incompatible_columns(table_diff_list: Sequence[DBTableDiff]) -> Dict[str, Any]:
    result = {}
    for table_diff in table_diff_list:
        columns_with_distinct_data_type = list(map(_generate_column_diff, table_diff.columns_with_distinct_data_type))
        result[table_diff.name] = {
            "columns_missing_in_source_database": table_diff.columns_missing_in_source_db,
            "columns_missing_in_target_database": table_diff.columns_missing_in_target_db,
            "columns_with_distinct_data_type": columns_with_distinct_data_type,
        }
    return result

 
def _generate_tables_with_incompatible_constraints(table_diff_list: Sequence[DBTableDiff]) -> Dict[str, Any]:
    result = {}
    for table_diff in table_diff_list:
        result[table_diff.name] = {
            "constraints_missing_in_source_db": table_diff.constraints_missing_in_source_db,
            "constraints_missing_in_target_db": table_diff.constraints_missing_in_target_db,
        }
    return result


def _generate_tables_with_incompatible_indexes(table_diff_list: Sequence[DBTableDiff]) -> Dict[str, Any]:
    result = {}
    for table_diff in table_diff_list:
        result[table_diff.name] = {
            "indexes_missing_in_source_database": table_diff.indexes_missing_in_source_db,
            "indexes_missing_in_target_database": table_diff.indexes_missing_in_target_db,
        }
    return result


def write_report(db_schema_diff: DBSchemaDiff, filename: str) -> None:
    console = Console(record=False)
    report = {
        "tables_missing_in_source_database": db_schema_diff.tables_missing_in_source_db(),
        "tables_missing_in_target_database": db_schema_diff.tables_missing_in_target_db(),
        "tables_with_distinct_columns": _generate_tables_with_incompatible_columns(db_schema_diff.tables_with_incompatible_columns()),
        "tables_with_distinct_constraints": _generate_tables_with_incompatible_constraints(db_schema_diff.tables_with_incompatible_constraints()),
        "tables_with_distinct_indexes": _generate_tables_with_incompatible_indexes(db_schema_diff.tables_with_incompatible_indexes()),
        "sequences_missing_in_source_database": db_schema_diff.sequences_missing_in_source_db(),
        "sequences_missing_in_target_database": db_schema_diff.sequences_missing_in_target_db(),
        "views_missing_in_source_database": db_schema_diff.views_missing_in_source_db(),
        "views_missing_in_target_database": db_schema_diff.views_missing_in_target_db(),
        "materialized_views_missing_in_source_database": db_schema_diff.materialized_views_missing_in_source_db(),
        "materialized_views_missing_in_target_database": db_schema_diff.materialized_views_missing_in_target_db(),
    }

    with open(filename, "w") as json_file:
        dump(report, json_file, indent=4)

    console.print()
    console.print(f"Comparison completed, details written to [cyan]{filename}[/cyan]")
