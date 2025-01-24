from dataclasses import dataclass
from typing import Any, Dict, Tuple

from colorama import Fore
from sqlalchemy import create_engine, inspect, MetaData

from rdbmsdiff.foundation import DatabaseProperties


# TODO: move this to foundation (see also schema validation)
@dataclass(frozen=True, slots=True)
class DBColumn:
    name: str
    datatype: Any
    nullable: bool


# TODO: move this to foundation (see also schema validation)
@dataclass(frozen=True, slots=True)
class DBTable:
    name: str
    columns: Tuple[DBColumn, ...]

    @property
    def column_count(self) -> int:
        return len(self.columns)


class _MetaDataReader:

    def __init__(self, db_properties: DatabaseProperties) -> None:
        self._db_properties = db_properties
        # TODO
        # it might make sense to promote this class to context manager and move this code
        # to its initialization method
        self._engine = create_engine(url=db_properties.url_with_password)
        self._inspection = inspect(self._engine)
        self._meta_data = MetaData(schema=db_properties.schema)
        self._meta_data.reflect(bind=self._engine)

    def read_tables(self) -> Dict[str, DBTable]:
        tables = {}
        print(f"{Fore.CYAN}TABLES{Fore.RESET}")
        for name, details in self._meta_data.tables.items():
            if name.startswith(self._db_properties.schema):
                tokens = name.split(".")
                name = tokens[1]
            table_meta_info = DBTable(
                name=name,
                columns=tuple(map(lambda c: DBColumn(name=c.name, datatype=c.type, nullable=c.nullable), details.columns)),
            )
            tables[name] = table_meta_info
            print(f"{name}: {table_meta_info.column_count} columns")
        print(f"Totally {len(tables)} tables")
        return tuple(tables)


def read_db_meta_data(db_properties: DatabaseProperties) -> Dict[str, DBTable]:
    print()
    print(f"Going to read meta-info from {Fore.CYAN}{db_properties.url_without_password}{Fore.RESET}, schema {Fore.CYAN}{db_properties.schema}{Fore.RESET}")

    # TODO: chances are we should take care about closing the reader
    reader = _MetaDataReader(db_properties)
    return reader.read_tables()
