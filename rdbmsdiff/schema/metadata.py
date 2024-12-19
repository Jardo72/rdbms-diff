from dataclasses import dataclass
from typing import Any, Dict, Set, Tuple

from colorama import Fore
from sqlalchemy import create_engine, inspect, MetaData

from foundation import DatabaseProperties


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


def read_db_meta_data(db_properties: DatabaseProperties) -> DBSchema:
    print()

    print(f"Going to read meta-info from {Fore.CYAN}{db_properties.url_without_password}{Fore.RESET}, schema {Fore.CYAN}{db_properties.schema}{Fore.RESET}")
    engine = create_engine(url=db_properties.url_with_password)
    inspection = inspect(engine)
    meta_data = MetaData(schema=db_properties.schema)
    meta_data.reflect(bind=engine)

    tables = []
    print(f"{Fore.CYAN}TABLES{Fore.RESET}")
    for name, details in meta_data.tables.items():
        if name.startswith(db_properties.schema):
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

    sequences = []
    print(f"{Fore.CYAN}SEQUENCES{Fore.RESET}")
    for name in inspection.get_sequence_names(db_properties.schema):
        print(name)
        sequences.append(name)
    print(f"Totally {len(sequences)} sequences")

    views = []
    print(f"{Fore.CYAN}VIEWS{Fore.RESET}")
    for name in inspection.get_view_names(db_properties.schema):
        print(name)
        views.append(name)
    print(f"Totally {len(views)} views")
 
    materialized_views = []
    print(f"{Fore.CYAN}MATERIALIZED VIEWS{Fore.RESET}")
    for name in inspection.get_materialized_view_names(db_properties.schema):
        print(name)
        materialized_views.append(name)
    print(f"Totally {len(materialized_views)} materialized views")
 
    return DBSchema(
        tables=tuple(tables),
        sequences=tuple(sequences),
        views=tuple(views),
        materialized_views=tuple(materialized_views)
    )
