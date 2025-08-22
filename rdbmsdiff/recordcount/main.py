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
from concurrent.futures import ThreadPoolExecutor
from dataclasses import dataclass
from typing import Dict, Optional, Sequence, Tuple

from rich.console import Console
from rich.table import Table
from rich.text import Text
from sqlalchemy import create_engine, func, select
from sqlalchemy import MetaData
from sqlalchemy.orm import Session

from rdbmsdiff.foundation import Configuration, DatabaseProperties, ReadConfigurationError, Status
from rdbmsdiff.foundation import epilog, handle_configuration_error, handle_general_error, read_config


@dataclass(frozen=True, slots=True)
class ComparisonResult:
    table: str
    source_record_count: Optional[int]
    target_record_count: Optional[int]

    @property
    def has_missing_record_count(self) -> bool:
        return self.source_record_count is None or self.target_record_count is None

    @property
    def source_record_count_as_str(self) -> str:
        return "N/A" if self.source_record_count is None else str(self.source_record_count)

    @property
    def target_record_count_as_str(self) -> str:
        return "N/A" if self.target_record_count is None else str(self.target_record_count)

    @property
    def status(self) -> Status:
        if self.has_missing_record_count:
            return Status.WARNING
        elif self.source_record_count == self.target_record_count:
            return Status.OK
        else:
            return Status.ERROR


def create_cmd_line_args_parser() -> ArgumentParser:
    parser = ArgumentParser(description="RDBMS Record Count Comparison Tool", formatter_class=RawTextHelpFormatter, epilog=epilog())

    # positional mandatory arguments
    parser.add_argument(
        "config_file",
        help="the name of the configuration file containing the connection strings and usernames"
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
        "-o", "--output-html",
        dest="output_html_file",
        default=None,
        help="optional name of an HTML output file the outcome of the comparison is to be written to"
    )

    return parser
 

def parse_cmd_line_args() -> Namespace:
    parser = create_cmd_line_args_parser()
    params = parser.parse_args()
    return params


def read_record_counts(db_properties: DatabaseProperties) -> Dict[str, int]:
    engine = create_engine(url=db_properties.url_with_password)
    meta_data = MetaData(schema=db_properties.schema)
    meta_data.reflect(bind=engine)
    with Session(engine) as session:
        result = {}
        for name, _ in meta_data.tables.items():
            table = meta_data.tables.get(name)
            statement = select(func.count()).select_from(table)
            record_count = session.execute(statement).scalar()
            if name.startswith(db_properties.schema):
                tokens = name.split(".")
                name = tokens[1]
            result[name] = record_count
        return result


def compare_record_counts(source_record_counts: Dict[str, int], target_record_counts: Dict[str, int]) -> Tuple[ComparisonResult, ...]:
    all_tables = set(source_record_counts.keys()).union(set(target_record_counts.keys()))
    result = []
    for table in sorted(all_tables):
        result.append(ComparisonResult(
            table=table,
            source_record_count = source_record_counts.get(table, None),
            target_record_count = target_record_counts.get(table, None),
        ))
    return tuple(result)


def print_comparison_results(config: Configuration, comparison_results: Sequence[ComparisonResult], output_html_file: str) -> None:
    console = Console(record=True, highlight=False)
    table = Table(title="[cyan]Record Count Comparison Results[/]", show_lines=True)

    table.add_column(Text("Table", justify="center"), justify="left")
    table.add_column(Text("Source DB Record Count", justify="center"), justify="right")
    table.add_column(Text("Target DB Record Count", justify="center"), justify="right")
    table.add_column(Text("Status", justify="center"), justify="center")

    for result in comparison_results:
        table.add_row(
            result.table,
            result.source_record_count_as_str,
            result.target_record_count_as_str,
            Status.format(result.status),
        )

    console.print()
    console.print(table)
    console.print()
    console.print(f"Source DB: [cyan]{config.source_db_config.url_without_password}[/cyan], schema [cyan]{config.source_db_config.schema}[/cyan]")
    console.print(f"Target DB: [cyan]{config.target_db_config.url_without_password}[/cyan], schema [cyan]{config.target_db_config.schema}[/cyan]")
    if output_html_file:
        console.save_html(output_html_file)


def main() -> None:
    try:
        console = Console(record=False, highlight=False)
        console.print()
        cmd_line_args = parse_cmd_line_args()
        config = read_config(cmd_line_args.config_file, cmd_line_args.ask_for_passwords)
        executor = ThreadPoolExecutor(max_workers=2)
        source_record_counts_future = executor.submit(read_record_counts, config.source_db_config)
        target_record_counts_future = executor.submit(read_record_counts, config.target_db_config)
        source_record_counts = source_record_counts_future.result()
        target_record_counts = target_record_counts_future.result()
        comparison_results = compare_record_counts(source_record_counts, target_record_counts)
        print_comparison_results(config, comparison_results, cmd_line_args.output_html_file)
    except ReadConfigurationError as e:
        handle_configuration_error(e)
    except Exception as e:
        handle_general_error(e)


if __name__ == "__main__":
    main()
