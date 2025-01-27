from argparse import ArgumentParser, Namespace, RawTextHelpFormatter

from rdbmsdiff.foundation import Configuration, DBSchema, ReadConfigurationError
from rdbmsdiff.foundation import epilog, handle_configuration_error, read_config, read_db_meta_data

from .report import Report
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

    return parser
 

def parse_cmd_line_args() -> Namespace:
    parser = create_cmd_line_args_parser()
    params = parser.parse_args()
    return params


def validate(config: Configuration, source_db_meta_data: DBSchema, target_db_meta_data: DBSchema, report_filename: str) -> None:
    report = Report(report_filename)
    try:
        engine = ValidationEngine(config, source_db_meta_data, target_db_meta_data, report)
        engine.validate()
    finally:
        if report is not None:
            report.close()


def main() -> None:
    try:
        cmd_line_args = parse_cmd_line_args()
        config = read_config(cmd_line_args.config_file, cmd_line_args.ask_for_passwords)
        source_db_meta_data = read_db_meta_data(config.source_db_config)
        target_db_meta_data = read_db_meta_data(config.target_db_config)
        validate(config, source_db_meta_data, target_db_meta_data, cmd_line_args.report)
    except ReadConfigurationError as e:
        handle_configuration_error(e)


if __name__ == "__main__":
    main()
