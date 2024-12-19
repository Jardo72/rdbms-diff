from argparse import ArgumentParser, Namespace, RawTextHelpFormatter

from colorama import init as colorama_init

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


def main() -> None:
    colorama_init()
    cmd_line_args = parse_cmd_line_args()
    config = read_config(cmd_line_args.config_file, cmd_line_args.ask_for_passwords)


if __name__ == "__main__":
    main()

