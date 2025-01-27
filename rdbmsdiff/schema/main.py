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

from argparse import ArgumentParser, Namespace, RawTextHelpFormatter
from dataclasses import dataclass
from typing import Tuple

from rich.console import Console
from rich.table import Table

from rdbmsdiff.foundation import ReadConfigurationError, Status
from rdbmsdiff.foundation import epilog, handle_configuration_error, read_config, read_db_meta_data
from .diff import DBSchemaDiff
from .report import write_report


@dataclass(frozen=True)
class SummaryRow:
    label: str
    discrepancy_count: int

    @property
    def discrepancy_count_as_str(self) -> str:
        return str(self.discrepancy_count)

    @property
    def status(self) -> Status:
        return Status.OK if self.discrepancy_count == 0 else Status.ERROR


def create_cmd_line_args_parser() -> ArgumentParser:
    parser = ArgumentParser(description="RDBMS Schema Comparison Tool", formatter_class=RawTextHelpFormatter, epilog=epilog())

    # positional mandatory arguments
    parser.add_argument(
        "config_file",
        help="the name of the configuration file containing the connection strings and usernames"
    )
    parser.add_argument(
        "diff_report",
        help="the name of the output JSON file the detailed outcome of the comparison is to be written to"
    )

    # optional arguments
    parser.add_argument(
        "-p", "--ask-for-passwords",
        dest="ask_for_passwords",
        default=False,
        action="store_true",
        help="if specified, the user will be asked for passwords (the passwords will not be read from env. variables)"
    )
    parser.add_argument(
        "-s", "--summary-html",
        dest="summary_html_file",
        default=None,
        help="optional name of an HTML output file the summary of the comparison is to be written to"
    )

    return parser
 

def parse_cmd_line_args() -> Namespace:
    parser = create_cmd_line_args_parser()
    params = parser.parse_args()
    return params


def create_summary_rows(db_schema_diff: DBSchemaDiff) -> Tuple[SummaryRow, ...]:
    result = [
        SummaryRow(label="Number of tables missing in source DB", discrepancy_count=db_schema_diff.number_of_tables_missing_in_source_db()),
        SummaryRow(label="Number of tables missing in target DB", discrepancy_count=db_schema_diff.number_of_tables_missing_in_target_db()),
        SummaryRow(label="Number of tables with distinct columns", discrepancy_count=db_schema_diff.number_of_tables_with_incompatible_columns()),
        SummaryRow(label="Number of tables with distinct constraints", discrepancy_count=db_schema_diff.number_of_tables_with_incompatible_constraints()),
        SummaryRow(label="Number of tables with distinct indexes", discrepancy_count=db_schema_diff.number_of_tables_with_incompatible_indexes()),
        SummaryRow(label="Number of sequences missing in source DB", discrepancy_count=db_schema_diff.number_of_sequences_missing_in_source_db()),
        SummaryRow(label="Number of sequences missing in target DB", discrepancy_count=db_schema_diff.number_of_sequences_missing_in_target_db()),
        SummaryRow(label="Number of views missing in source DB", discrepancy_count=db_schema_diff.number_of_views_missing_in_source_db()),
        SummaryRow(label="Number of views missing in target DB", discrepancy_count=db_schema_diff.number_of_views_missing_in_target_db()),
        SummaryRow(label="Number of materialized views missing in source DB", discrepancy_count=db_schema_diff.number_of_materialized_views_missing_in_source_db()),
        SummaryRow(label="Number of materialized views missing in target DB", discrepancy_count=db_schema_diff.number_of_materialized_views_missing_in_target_db()),
    ]
    return tuple(result)


def print_summary(db_schema_diff: DBSchemaDiff, summary_html_file: str) -> None:
    console = Console(record=True)
    table = Table(title="Schema Comparison Summary", show_lines=True)

    table.add_column("Discrepancy", justify="left")
    table.add_column("Count", justify="right")
    table.add_column("Status", justify="center")

    for row in create_summary_rows(db_schema_diff):
        table.add_row(
            row.label,
            row.discrepancy_count_as_str,
            Status.format(row.status),
        )

    console.print()
    console.print(table)
    if summary_html_file:
        console.save_html(summary_html_file)


def main() -> None:
    try:
        cmd_line_args = parse_cmd_line_args()
        config = read_config(cmd_line_args.config_file, cmd_line_args.ask_for_passwords)
        source_meta_data = read_db_meta_data(config.source_db_config)
        target_meta_data = read_db_meta_data(config.target_db_config)
        schema_diff = DBSchemaDiff(source_schema=source_meta_data, target_schema=target_meta_data)
        write_report(schema_diff, cmd_line_args.diff_report)
        print_summary(schema_diff, cmd_line_args.summary_html_file)
    except ReadConfigurationError as e:
        handle_configuration_error(e)


if __name__ == "__main__":
    main()
