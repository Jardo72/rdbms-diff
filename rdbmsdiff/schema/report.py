from json import dump
from typing import Any, Dict, Sequence

from colorama import Fore

from .diff import DBSchemaDiff, DBTableDiff



def _convert_tables_with_incompatible_columns(table_diff_list: Sequence[DBTableDiff]) -> Dict[str, Any]:
    result = {}
    for table_diff in table_diff_list:
        columns_with_distinct_data_type = list(map(convert_column_diff, table_diff.columns_with_distinct_data_type))
        result[table_diff.name] = {
            "columns_missing_in_source_database": table_diff.columns_missing_in_source_db,
            "columns_missing_in_target_database": table_diff.columns_missing_in_target_db,
            "columns_with_distinct_data_type": columns_with_distinct_data_type,
        }
    return result

 

 

def _convert_tables_with_incompatible_constraints(table_diff_list: Sequence[DBTableDiff]) -> Dict[str, Any]:
    result = {}
    for table_diff in table_diff_list:
        result[table_diff.name] = {
            "constraints_missing_in_source_db": table_diff.constraints_missing_in_source_db,
            "constraints_missing_in_target_db": table_diff.constraints_missing_in_target_db,
        }
    return result



def _convert_tables_with_incompatible_indexes(table_diff_list: Sequence[DBTableDiff]) -> Dict[str, Any]:
    result = {}
    for table_diff in table_diff_list:
        result[table_diff.name] = {
            "indexes_missing_in_source_database": table_diff.indexes_missing_in_source_db,
            "indexes_missing_in_target_database": table_diff.indexes_missing_in_target_db,
        }
    return result


def write_report(db_schema_diff: DBSchemaDiff, filename: str) -> None:
    report = {
        "tables_missing_in_source_database": db_schema_diff.tables_missing_in_source_db(),
        "tables_missing_in_target_database": db_schema_diff.tables_missing_in_target_db(),
        "tables_with_distinct_columns": _convert_tables_with_incompatible_columns(db_schema_diff.tables_with_incompatible_columns()),
        "tables_with_distinct_constraints": _convert_tables_with_incompatible_constraints(db_schema_diff.tables_with_incompatible_constraints()),
        "tables_with_distinct_indexes": _convert_tables_with_incompatible_indexes(db_schema_diff.tables_with_incompatible_indexes()),
        "sequences_missing_in_source_database": db_schema_diff.sequences_missing_in_source_db(),
        "sequences_missing_in_target_database": db_schema_diff.sequences_missing_in_target_db(),
        "views_missing_in_source_database": db_schema_diff.views_missing_in_source_db(),
        "views_missing_in_target_database": db_schema_diff.views_missing_in_target_db(),
        "materialized_views_missing_in_source_database": db_schema_diff.materialized_views_missing_in_source_db(),
        "materialized_views_missing_in_target_database": db_schema_diff.materialized_views_missing_in_target_db(),
    }

    with open(filename, "w") as json_file:
        dump(report, json_file, indent=4)

    print()
    print(f"Comparison completed, details written to {Fore.CYAN}{filename}{Fore.RESET}")
