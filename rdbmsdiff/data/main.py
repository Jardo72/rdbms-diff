from argparse import ArgumentParser, Namespace, RawTextHelpFormatter

from rich.console import Console
from rich.table import Table

from rdbmsdiff.foundation import Configuration, DBSchema, ReadConfigurationError, Status
from rdbmsdiff.foundation import epilog, handle_configuration_error, read_config, read_db_meta_data

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


def print_summary(statistics: Statistics, summary_html_file: str) -> None:
    console = Console(record=True)
    table = Table(title="Data Comparison Summary", show_lines=True)

    table.add_column("Subject", justify="left")
    table.add_column("Overall Count", justify="right")
    table.add_column("Failure Count", justify="right")
    table.add_column("Status", justify="center")

    table.add_row(
        "Tables",
        str(statistics.overall_table_count),
        str(statistics.failed_table_count),
        Status.format(Status.OK if statistics.failed_table_count == 0 else Status.ERROR),
    )
    table.add_row(
        "Validation",
        str(statistics.overall_validation_count),
        str(statistics.failed_validation_count),
        Status.format(Status.OK if statistics.failed_validation_count == 0 else Status.ERROR),
    )

    console.print()
    console.print(table)
    if summary_html_file:
        console.save_html(summary_html_file)


def main() -> None:
    try:
        cmd_line_args = parse_cmd_line_args()
        config = read_config(cmd_line_args.config_file, cmd_line_args.ask_for_passwords)
        source_db_meta_data = read_db_meta_data(config.source_db_config)
        target_db_meta_data = read_db_meta_data(config.target_db_config)
        statistics = validate(config, source_db_meta_data, target_db_meta_data, cmd_line_args.report)
        print_summary(statistics, cmd_line_args.summary_html_file)
    except ReadConfigurationError as e:
        handle_configuration_error(e)


if __name__ == "__main__":
    main()
