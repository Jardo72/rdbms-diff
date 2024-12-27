from dataclasses import dataclass
from typing import Any, Dict, Set, Tuple

from colorama import Fore
from sqlalchemy import create_engine, inspect, MetaData

from rdbmsdiff.foundation import DatabaseProperties


@dataclass(frozen=True, slots=True)
class DBColumn:
    name: str
    datatype: Any


@dataclass(frozen=True, slots=True)
class DBTable:
    name: str
    columns: Tuple[DBColumn, ...]
    constraints: Tuple[str, ...]
    indexes: Tuple[str, ...]
 
    @property
    def columns_as_dict(self) -> Dict[str, DBColumn]:
        result = {}
        for column in self.columns:
            result[column.name] = column
        return result

    @property
    def column_count(self) -> int:
        return len(self.columns)

    @property
    def constraint_count(self) -> int:
        return len(self.constraints)

    @property
    def index_count(self) -> int:
        return len(self.indexes)

    @property
    def column_names_as_set(self) -> Set[str]:
        return set([column.name for column in self.columns])

    @property
    def constraint_names_as_set(self) -> Set[str]:
        return set(self.constraints)

    @property
    def index_names_as_set(self) -> Set[str]:
        return set(self.indexes)
    

@dataclass(frozen=True, slots=True)
class DBSchema:
    tables: Tuple[DBTable, ...]
    sequences: Tuple[str, ...]
    views: Tuple[str, ...]
    materialized_views: Tuple[str, ...]


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

    def read_meta_data(self) -> DBSchema:
        return DBSchema(
            tables=self._read_tables(),
            sequences=self._read_sequences(),
            views=self._read_views(),
            materialized_views=self._read_materialized_views(),
        )

    def _read_tables(self) -> Tuple[DBTable, ...]:
        tables = []
        print(f"{Fore.CYAN}TABLES{Fore.RESET}")
        for name, details in self._meta_data.tables.items():
            if name.startswith(self._db_properties.schema):
                tokens = name.split(".")
                name = tokens[1]
            table_meta_info = DBTable(
                name=name,
                columns=tuple(map(lambda c: DBColumn(name=c.name, datatype=c.type), details.columns)),
                constraints=tuple([constraint.name for constraint in details.constraints]),
                indexes=tuple([index.name for index in details.indexes])
            )
            tables.append(table_meta_info)
            print(f"{name}: {table_meta_info.column_count} columns/{table_meta_info.constraint_count} constraints/{table_meta_info.index_count} indexes")
        print(f"Totally {len(tables)} tables")
        return tuple(tables)

    def _read_sequences(self) -> Tuple[str, ...]:
        sequences = []
        print(f"{Fore.CYAN}SEQUENCES{Fore.RESET}")
        for name in self._inspection.get_sequence_names(self._db_properties.schema):
            print(name)
            sequences.append(name)
        print(f"Totally {len(sequences)} sequences")
        return tuple(sequences)

    def _read_views(self) -> Tuple[str, ...]:
        views = []
        print(f"{Fore.CYAN}VIEWS{Fore.RESET}")
        for name in self._inspection.get_view_names(self._db_properties.schema):
            print(name)
            views.append(name)
        print(f"Totally {len(views)} views")
        return tuple(views)

    def _read_materialized_views(self) -> Tuple[str, ...]:
        materialized_views = []
        print(f"{Fore.CYAN}MATERIALIZED VIEWS{Fore.RESET}")
        for name in self._inspection.get_materialized_view_names(self._db_properties.schema):
            print(name)
            materialized_views.append(name)
        print(f"Totally {len(materialized_views)} materialized views")
        return tuple(materialized_views)


def read_db_meta_data(db_properties: DatabaseProperties) -> DBSchema:
    print()
    print(f"Going to read meta-info from {Fore.CYAN}{db_properties.url_without_password}{Fore.RESET}, schema {Fore.CYAN}{db_properties.schema}{Fore.RESET}")

    # chances are we should take care about closing the reader
    reader = _MetaDataReader(db_properties)
    return reader.read_meta_data()
