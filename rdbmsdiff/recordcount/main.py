from argparse import ArgumentParser, Namespace, RawTextHelpFormatter
from typing import Dict

from colorama import Fore
from colorama import init as colorama_init
from sqlalchemy import create_engine, select
from sqlalchemy import MetaData
from sqlalchemy.orm import Session

from rdbmsdiff.foundation import DatabaseProperties
from rdbmsdiff.foundation import epilog, read_config


def create_cmd_line_args_parser() -> ArgumentParser:
    parser = ArgumentParser(description="Database Record Count Comparison Tool", formatter_class=RawTextHelpFormatter, epilog=epilog())

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

    return parser
 

def parse_cmd_line_args() -> Namespace:
    parser = create_cmd_line_args_parser()
    params = parser.parse_args()
    return params


def read_record_counts(db_properties: DatabaseProperties) -> Dict[str, int]:
    print()
    print(f"Going to read record counts from {Fore.CYAN}{db_properties.url_without_password}{Fore.RESET}, schema {Fore.CYAN}{db_properties.schema}{Fore.RESET}")
    engine = create_engine(url=db_properties.url_with_password)
    meta_data = MetaData(schema=db_properties.schema)
    meta_data.reflect(bind=engine)
    with Session(engine) as session:
        result = {}
        for name, _ in meta_data.tables.items():
            table = meta_data.tables.get(name)
            statement = select().select_from(table)
            record_count = session.execute(statement).scalar()
            if name.startswith(db_properties.schema):
                tokens = name.split(".")
                name = tokens[1]
            result[name] = record_count
            print(f"{name} -> {record_count} records")
        return result


def compare_record_counts(source_record_counts: Dict[str, int], target_record_counts: Dict[str, int]) -> None:
    ...


def main() -> None:
    colorama_init()
    cmd_line_args = parse_cmd_line_args()
    config = read_config(cmd_line_args.config_file, cmd_line_args.ask_for_passwords)
    source_record_counts = read_record_counts(config.source_db_config)
    target_record_counts = read_record_counts(config.target_db_config)
    compare_record_counts(source_record_counts, target_record_counts)


if __name__ == "__main__":
    main()
