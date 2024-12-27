from argparse import ArgumentParser, Namespace, RawTextHelpFormatter

from colorama import init as colorama_init, Fore

from rdbmsdiff.foundation import epilog, read_config
from .diff import DBSchemaDiff
from .metadata import read_db_meta_data


def create_cmd_line_args_parser() -> ArgumentParser:
    parser = ArgumentParser(description="Database Schema Comparison Tool", formatter_class=RawTextHelpFormatter, epilog=epilog())

    # positional mandatory arguments
    parser.add_argument(
        "config_file",
        help="the name of the configuration file containing the connection strings and usernames"
    )
    parser.add_argument(
        "diff_report",
        help="the name of the output JSON file the outcome of the comparison is to be written to"
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


def print_value(label: str, value: int) -> None:
    color = Fore.GREEN if value == 0 else Fore.RED
    label = (label + ":").ljust(52)
    print(f"{color}{label}{value}{Fore.RESET}")


def print_summary(db_schema_diff: DBSchemaDiff) -> None:
    print()
    print("SUMMARY")

    print_value("Number of tables missing in source DB", db_schema_diff.number_of_tables_missing_in_source_db())
    print_value("Number of tables missing in target DB", db_schema_diff.number_of_tables_missing_in_target_db())
    print_value("Number of tables with distinct columns", db_schema_diff.number_of_tables_with_incompatible_columns())
    print_value("Number of tables with distinct constraints", db_schema_diff.number_of_tables_with_incompatible_constraints())
    print_value("Number of tables with distinct indexes", db_schema_diff.number_of_tables_with_incompatible_indexes())
    print_value("Number of sequences missing in source DB", db_schema_diff.number_of_sequences_missing_in_source_db())
    print_value("Number of sequences missing in target DB", db_schema_diff.number_of_sequences_missing_in_target_db())
    print_value("Number of views missing in source DB", db_schema_diff.number_of_views_missing_in_source_db())
    print_value("Number of views missing in target DB", db_schema_diff.number_of_views_missing_in_target_db())
    print_value("Number of materialized views missing in source DB", db_schema_diff.number_of_materialized_views_missing_in_source_db())
    print_value("Number of materialized views missing in target DB", db_schema_diff.number_of_materialized_views_missing_in_target_db())


def main() -> None:
    colorama_init()
    cmd_line_args = parse_cmd_line_args()
    config = read_config(cmd_line_args.config_file, cmd_line_args.ask_for_passwords)
    source_meta_data = read_db_meta_data(config.source_db_config)
    target_meta_data = read_db_meta_data(config.target_db_config)


if __name__ == "__main__":
    main()
