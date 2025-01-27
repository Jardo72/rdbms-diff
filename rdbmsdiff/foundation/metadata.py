from dataclasses import dataclass
from typing import Any, Dict, Set, Tuple

from rich.console import Console
from sqlalchemy import create_engine, inspect, MetaData
from sqlalchemy.sql.schema import CheckConstraint, ForeignKeyConstraint, PrimaryKeyConstraint, UniqueConstraint
from sqlalchemy.sql.sqltypes import BIGINT, BOOLEAN, DOUBLE, FLOAT, INTEGER, SMALLINT, TEXT, VARCHAR

from .config import DatabaseProperties


@dataclass(frozen=True, slots=True)
class DBColumn:
    name: str
    datatype: Any
    nullable: bool

    @property
    def is_numeric(self) -> bool:
        return (
            isinstance(self.datatype, SMALLINT) or
            isinstance(self.datatype, INTEGER) or
            isinstance(self.datatype, BIGINT) or
            isinstance(self.datatype, FLOAT) or
            isinstance(self.datatype, DOUBLE)
        )

    @property
    def is_string(self) -> bool:
        return (
            isinstance(self.datatype, VARCHAR) or
            isinstance(self.datatype, TEXT)
        )

    @property
    def is_boolean(self) -> bool:
        return isinstance(self.datatype, BOOLEAN)


@dataclass(frozen=True, slots=True)
class DBTable:
    name: str
    columns: Tuple[DBColumn, ...]
    check_constraints: Tuple[CheckConstraint, ...]
    unique_constraints: Tuple[UniqueConstraint, ...]
    # TODO: I think there can only be one PK per table
    primary_key_constraints: Tuple[PrimaryKeyConstraint, ...]
    foreign_key_constraints: Tuple[ForeignKeyConstraint, ...]
    indexes: Tuple[str, ...]

    @property
    def columns_as_dict(self) -> Dict[str, DBColumn]:
        result = {}
        for column in self.columns:
            result[column.name] = column
        return result

    @property
    def column_names_as_set(self) -> Set[str]:
        return set([column.name for column in self.columns])

    @property
    def column_count(self) -> int:
        return len(self.columns)

    @property
    def constraint_count(self) -> int:
        return len(self.check_constraints) + len(self.unique_constraints) + len(self.primary_key_constraints) + len(self.foreign_key_constraints)

    @property
    def index_count(self) -> int:
        return len(self.indexes)


@dataclass(frozen=True, slots=True)
class DBSchema:
    tables: Tuple[DBTable, ...]
    sequences: Tuple[str, ...]
    views: Tuple[str, ...]
    materialized_views: Tuple[str, ...]


class _MetaDataReader:

    def __init__(self, db_properties: DatabaseProperties, console: Console) -> None:
        self._db_properties = db_properties
        # TODO
        # it might make sense to promote this class to context manager and move this code
        # to its initialization method
        self._engine = create_engine(url=db_properties.url_with_password)
        self._inspection = inspect(self._engine)
        self._meta_data = MetaData(schema=db_properties.schema)
        self._meta_data.reflect(bind=self._engine)
        self._console = console

    def read_meta_data(self) -> DBSchema:
        return DBSchema(
            tables=self._read_tables(),
            sequences=self._read_sequences(),
            views=self._read_views(),
            materialized_views=self._read_materialized_views(),
        )

    def _read_tables(self) -> Tuple[DBTable, ...]:
        tables = []
        self._console.print(f"[cyan]TABLES[/cyan]")
        for name, details in self._meta_data.tables.items():
            if name.startswith(self._db_properties.schema):
                tokens = name.split(".")
                name = tokens[1]
            table_meta_info = DBTable(
                name=name,
                columns=tuple(map(lambda c: DBColumn(name=c.name, datatype=c.type, nullable=c.nullable), details.columns)),
                check_constraints=tuple([constraint for constraint in details.constraints if isinstance(constraint, CheckConstraint)]),
                unique_constraints=tuple([constraint for constraint in details.constraints if isinstance(constraint, UniqueConstraint)]),
                primary_key_constraints=tuple([constraint for constraint in details.constraints if isinstance(constraint, PrimaryKeyConstraint)]),
                foreign_key_constraints=tuple([constraint for constraint in details.constraints if isinstance(constraint, ForeignKeyConstraint)]),
                indexes=tuple([index.name for index in details.indexes])
            )
            tables.append(table_meta_info)
            self._console.print(f"{name}: {table_meta_info.column_count} columns/{table_meta_info.constraint_count} constraints/{table_meta_info.index_count} indexes")
        self._console.print(f"Totally {len(tables)} tables")
        return tuple(tables)

    def _read_sequences(self) -> Tuple[str, ...]:
        sequences = []
        self._console.print(f"[cyan]SEQUENCES[/cyan]")
        for name in self._inspection.get_sequence_names(self._db_properties.schema):
            print(name)
            sequences.append(name)
        self._console.print(f"Totally {len(sequences)} sequences")
        return tuple(sequences)

    def _read_views(self) -> Tuple[str, ...]:
        views = []
        self._console.print(f"[cyan]VIEWS[/cyan]")
        for name in self._inspection.get_view_names(self._db_properties.schema):
            print(name)
            views.append(name)
        self._console.print(f"Totally {len(views)} views")
        return tuple(views)

    def _read_materialized_views(self) -> Tuple[str, ...]:
        materialized_views = []
        self._console.print(f"[cyan]MATERIALIZED VIEWS[/cyan]")
        for name in self._inspection.get_materialized_view_names(self._db_properties.schema):
            print(name)
            materialized_views.append(name)
        self._console.print(f"Totally {len(materialized_views)} materialized views")
        return tuple(materialized_views)


def read_db_meta_data(db_properties: DatabaseProperties) -> DBSchema:
    console = Console(record=False, highlight=False)
    console.print()
    console.print(f"Going to read meta-info from [cyan]{db_properties.url_without_password}[/cyan], schema [cyan]{db_properties.schema}[/cyan]")

    # TODO: chances are we should take care about closing the reader
    reader = _MetaDataReader(db_properties, console)
    return reader.read_meta_data()
