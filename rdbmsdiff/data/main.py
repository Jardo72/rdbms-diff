from argparse import ArgumentParser, Namespace, RawTextHelpFormatter

from sqlalchemy.sql.sqltypes import BIGINT, BOOLEAN, DOUBLE, FLOAT, INTEGER, SMALLINT, TEXT, VARCHAR

from rdbmsdiff.foundation import Configuration, DBColumn, DBSchema, ReadConfigurationError
from rdbmsdiff.foundation import epilog, handle_configuration_error, read_config, read_db_meta_data

from .boolean_validator import BooleanValidator
from .null_value_count_validator import NullValueCheckType, NullValueCountValidator
from .numeric_validator import NumericValidator
from .varchar_length_validator import VarcharLengthValidator


def create_cmd_line_args_parser() -> ArgumentParser:
    parser = ArgumentParser(description="RDBMS Data Comparison Tool", formatter_class=RawTextHelpFormatter, epilog=epilog())

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


# TODO: this might be moved to DBColumn
def is_numeric(column: DBColumn) -> bool:
    return (
        isinstance(column.datatype, SMALLINT) or
        isinstance(column.datatype, INTEGER) or
        isinstance(column.datatype, BIGINT) or
        isinstance(column.datatype, FLOAT) or
        isinstance(column.datatype, DOUBLE)
    )


# TODO: this might be moved to DBColumn
def is_string(column: DBColumn) -> bool:
    return (
        isinstance(column.datatype, VARCHAR) or
        isinstance(column.datatype, TEXT)
    )


def introspect(config: Configuration, db_meta_data: DBSchema) -> None:
    for table in db_meta_data.tables:
        print()
        print(table.name)
        for column in table.columns:
            if is_numeric(column):
                print(f"{column.name} -> numeric")
                validator = NumericValidator(config, table, column)
                result = validator.validate()
                print(f"Result\n{result}")
            elif is_string(column):
                print(f"{column.name} -> string")
                validator = VarcharLengthValidator(config, table, column)
                result = validator.validate()
                print(f"Result\n{result}")
            elif isinstance(column.datatype, BOOLEAN):
                print(f"{column.name} -> boolean")
                validator = BooleanValidator(config, table, column)
                result = validator.validate()
                print(f"Result\n{result}")
            if column.nullable:
                print(f"{column.name} is nullable")
                validator = NullValueCountValidator(config, table, column, NullValueCheckType.IS_NULL)
                result = validator.validate()
                print(f"Result\n{result}")
                validator = NullValueCountValidator(config, table, column, NullValueCheckType.IS_NOT_NULL)
                result = validator.validate()
                print(f"Result\n{result}")


def main() -> None:
    try:
        cmd_line_args = parse_cmd_line_args()
        config = read_config(cmd_line_args.config_file, cmd_line_args.ask_for_passwords)
        source_meta_data = read_db_meta_data(config.source_db_config)
        target_meta_data = read_db_meta_data(config.target_db_config)
        introspect(config, source_meta_data)
    except ReadConfigurationError as e:
        handle_configuration_error(e)


if __name__ == "__main__":
    main()
