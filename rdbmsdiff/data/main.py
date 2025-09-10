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

from argparse import (
    ArgumentParser,
    Namespace,
    RawTextHelpFormatter,
)

from rich.console import Console
from rich.padding import Padding
from rich.table import Table
from rich.text import Text

from rdbmsdiff.foundation import (
    Configuration,
    DBSchema,
    ReadConfigurationError,
    Status,
    epilog,
    handle_configuration_error,
    handle_general_error,
    print_banner,
    read_config,
    read_db_meta_data,
)

from .report import Report, Statistics
from .validation_engine import ValidationEngine


def create_cmd_line_args_parser() -> ArgumentParser:
    parser = ArgumentParser(description="RDBMS Data Comparison Tool", formatter_class=RawTextHelpFormatter, epilog=epilog())

    # positional mandatory arguments
    parser.add_argument(
        "config_file",
        help="the name of the configuration file containing the connection strings and usernames"
    )
    parser.add_argument(
        "report",
        help="the name of the output text file the outcome of the comparison is to be written to"
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


def validate(config: Configuration, source_db_meta_data: DBSchema, target_db_meta_data: DBSchema, report_filename: str) -> Statistics:
    report = Report(report_filename)
    try:
        engine = ValidationEngine(config, source_db_meta_data, target_db_meta_data, report)
        engine.validate()
        return report.get_statistics()
    finally:
        if report is not None:
            report.close()


def print_summary(config: Configuration, statistics: Statistics, summary_html_file: str) -> None:
    console = Console(record=True, highlight=False)
    table = Table(title="[cyan]Data Comparison Summary[/]", show_lines=True)

    table.add_column(Text("Subject", justify="center"), justify="left")
    table.add_column(Text("Overall Count", justify="center"), justify="right")
    table.add_column(Text("Success Count", justify="center"), justify="right")
    table.add_column(Text("Failure Count", justify="center"), justify="right")
    table.add_column(Text("Status", justify="center"), justify="center")

    table.add_row(
        "Tables",
        str(statistics.overall_table_count),
        str(statistics.succsessful_table_count),
        str(statistics.failed_table_count),
        Status.format(Status.OK if statistics.failed_table_count == 0 else Status.ERROR),
    )
    table.add_row(
        "Validations",
        str(statistics.overall_validation_count),
        str(statistics.successful_validation_count),
        str(statistics.failed_validation_count),
        Status.format(Status.OK if statistics.failed_validation_count == 0 else Status.ERROR),
    )

    console.print()
    console.print(Padding(table, (1, 2)))
    console.print()
    console.print(f"Source DB: [cyan]{config.source_db_config.url_without_password}[/], schema [cyan]{config.source_db_config.schema}[/]")
    console.print(f"Target DB: [cyan]{config.target_db_config.url_without_password}[/], schema [cyan]{config.target_db_config.schema}[/]")
    if summary_html_file:
        console.save_html(summary_html_file)


def main() -> None:
    try:
        print_banner()
        cmd_line_args = parse_cmd_line_args()
        config = read_config(cmd_line_args.config_file, cmd_line_args.ask_for_passwords)
        source_db_meta_data = read_db_meta_data(config.source_db_config)
        target_db_meta_data = read_db_meta_data(config.target_db_config)
        statistics = validate(config, source_db_meta_data, target_db_meta_data, cmd_line_args.report)
        print_summary(config, statistics, cmd_line_args.summary_html_file)
    except ReadConfigurationError as e:
        handle_configuration_error(e)
    except Exception as e:
        handle_general_error(e)


if __name__ == "__main__":
    main()
