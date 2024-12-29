from argparse import ArgumentParser, Namespace, RawTextHelpFormatter
from dataclasses import dataclass
from enum import Enum, unique
from typing import Dict, Optional, Sequence, Tuple

from rich.console import Console
from rich.table import Table
from sqlalchemy import create_engine, func, select
from sqlalchemy import MetaData
from sqlalchemy.orm import Session

from rdbmsdiff.foundation import DatabaseProperties
from rdbmsdiff.foundation import epilog, read_config


@unique
class Status(Enum):
    OK = 1
    WARNING = 2
    ERROR = 3


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
    console = Console(record=False, highlight=False)
    console.print()
    console.print(f"Going to read record counts from [cyan]{db_properties.url_without_password}[/cyan], schema [cyan]{db_properties.schema}[/cyan]")
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
            console.print(f"{name} -> {record_count} records")
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


def print_status(status: Status) -> str:
    if status == Status.OK:
        return f"[green]{status.name}[/green]"
    elif status == Status.WARNING:
        return f"[yellow]{status.name}[/yellow]"
    else:
        return f"[red]{status.name}[/red]"


def print_comparison_results(comparison_results: Sequence[ComparisonResult], output_html_file: str) -> None:
    console = Console(record=True)
    table = Table(title="Record Count Comparison Results", show_lines=True)

    table.add_column("Table", justify="left")
    table.add_column("Source DB Record Count", justify="right")
    table.add_column("Target DB Record Count", justify="right")
    table.add_column("Status", justify="center")

    for result in comparison_results:
        table.add_row(
            result.table,
            result.source_record_count_as_str,
            result.target_record_count_as_str,
            print_status(result.status),
        )

    console.print()
    console.print(table)
    if output_html_file:
        console.save_html(output_html_file)


def main() -> None:
    cmd_line_args = parse_cmd_line_args()
    config = read_config(cmd_line_args.config_file, cmd_line_args.ask_for_passwords)
    source_record_counts = read_record_counts(config.source_db_config)
    target_record_counts = read_record_counts(config.target_db_config)
    comparison_results = compare_record_counts(source_record_counts, target_record_counts)
    print_comparison_results(comparison_results, cmd_line_args.output_html_file)


if __name__ == "__main__":
    main()
