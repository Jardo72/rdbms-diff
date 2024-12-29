from configparser import ConfigParser
from dataclasses import dataclass
from getpass import getpass
from os import environ
from os.path import exists, isfile


@dataclass(frozen=True, slots=True)
class Passwords:
    source_db_password: str
    target_db_password: str


@dataclass(frozen=True, slots=True)
class DatabaseProperties:
    url: str
    schema: str
    password: str

    @property
    def url_with_password(self) -> str:
        return self.url.replace("${password}", self.password)

    @property
    def url_without_password(self) -> str:
        return self.url


@dataclass(frozen=True, slots=True)
class Configuration:
    source_db_config: DatabaseProperties
    target_db_config: DatabaseProperties


class ReadConfigurationError(Exception):
    ...


def _read_passwords_from_input() -> Passwords:
    return Passwords(
        source_db_password=getpass("Enter the source DB password: "),
        target_db_password=getpass("Enter the target DB password: "),
    )


def _read_password_from_environment(var_name: str) -> str:
    if var_name not in environ:
        message = f"Cannot read password from environment variable {var_name} (variable not set)."
        raise ReadConfigurationError(message)
    result = environ[var_name]
    if result == "":
        message = f"Cannot read password from environment variable {var_name} (variable set to empty string)."
        raise ReadConfigurationError(message)
    return result


def _read_passwords_from_environment() -> Passwords:
    return Passwords(
        source_db_password=_read_password_from_environment("RDBMS_DIFF_SOURCE_DB_PASSWORD"),
        target_db_password=_read_password_from_environment("RDBMS_DIFF_TARGET_DB_PASSWORD"),
    )


def read_config(filename: str, ask_for_passwords: bool) -> Configuration:
    if not exists(filename):
        message = f"Cannot read configuration file {filename} (no such file)."
        raise ReadConfigurationError(message)
    if not isfile(filename):
        message = f"Cannot read configuration file {filename} (not a file)."
        raise ReadConfigurationError(message)
    config = ConfigParser()
    config.read(filename)
    passwords = _read_passwords_from_input() if ask_for_passwords else _read_passwords_from_environment()
    return Configuration(
        source_db_config=DatabaseProperties(
            url=config["DB.Source"]["URL"],
            schema=config["DB.Source"]["Schema"],
            password=passwords.source_db_password,
        ),
        target_db_config=DatabaseProperties(
            url=config["DB.Target"]["URL"],
            schema=config["DB.Target"]["Schema"],
            password=passwords.target_db_password,
        ),
    )


def epilog() -> str:
    return """
The following snippet illustrates the expected structure of the configuration file. The passwords
are not specified in the configuration. The DB URLs only contain placeholders which will be replaced
at run-time. The application either prompts the user for the passwords, or it reads the passwords
from environment variables (RDBMS_DIFF_SOURCE_DB_PASSWORD, RDBMS_DIFF_TARGET_DB_PASSWORD). Command
line arguments determine the origin of the passwords. If the user is asked for the passwords, they
are entered in a way that does not reveal them (i.e. they are not visible in the console window).

[DB.Source]
URL = postgresql+psycopg2://read_only_user:${password}@azdsefcontroldb-prod.cyp9qcizrvhv.eu-central-1.rds.amazonaws.com:5432/demo_source_db
Schema = demo_source_schema

[DB.Target]
# if you need an SSH tunnel to connect to a database, this is an example how to create it
# ssh -L 5432:demo-aurora-cluster.cluster-ch4i0w4kcjlr.eu-central-1.rds.amazonaws.com:5432 ec2-user@db-migraton-jumphost
URL = postgresql+psycopg2://masteruser:${password}@localhost:5432/demo_target_db
Schema = demo_target_schema
"""
