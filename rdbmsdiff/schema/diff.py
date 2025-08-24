#
# Copyright 2025 Jaroslav Chmurny
#
# This file is part of RDBMS Diff.
#
# RDBMS Diff is free software licensed under the Apache License,
# Version 2.0 (the "License"); you may not use this file except in
# compliance with the License. You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

from dataclasses import dataclass
from typing import (
    Any,
    Optional,
    Sequence,
    Tuple
)

from rdbmsdiff.foundation import (
    DBSchema,
    DBTable,
)


@dataclass(frozen=True, slots=True)
class DBColumnDiff:
    name: str
    source_data_type: Any
    target_data_type: Any


@dataclass(frozen=True, slots=True)
class DBTableColumnsDiff:
    columns_missing_in_source_db: Tuple[str, ...]
    columns_missing_in_target_db: Tuple[str, ...]
    columns_with_distinct_data_type: Tuple[DBColumnDiff, ...]

    def is_empty(self) -> bool:
        return (
            len(self.columns_missing_in_source_db) == 0 and
            len(self.columns_missing_in_target_db) == 0 and
            len(self.columns_with_distinct_data_type) == 0
        )


@dataclass(frozen=True, slots=True)
class DBTableEnhancementsDiff:
    names_missing_in_source_db: Tuple[str, ...]
    names_missing_in_target_db: Tuple[str, ...]

    def is_empty(self) -> bool:
        return (
            len(self.names_missing_in_source_db) == 0 and
            len(self.names_missing_in_target_db) == 0
        )
    

_EMPTY_TUPLE = tuple()


@dataclass(frozen=True, slots=True)
class DBTableDiff:
    name: str
    column_diff: Optional[DBTableColumnsDiff]
    constraint_diff: Optional[DBTableEnhancementsDiff]
    index_diff: Optional[DBTableEnhancementsDiff]

    def has_column_discrepancies(self) -> bool:
        if self.column_diff is None:
            return False
        return not self.column_diff.is_empty()

    def has_constraint_discrepancies(self) -> bool:
        if self.constraint_diff is None:
            return False
        return not self.constraint_diff.is_empty()

    def has_index_discrepancies(self) -> bool:
        if self.index_diff is None:
            return False
        return not self.index_diff.is_empty()

    @property
    def columns_missing_in_source_db(self) -> Tuple[str, ...]:
        return self.column_diff.columns_missing_in_source_db if self.column_diff else _EMPTY_TUPLE

    @property
    def columns_missing_in_target_db(self) -> Tuple[str, ...]:
        return self.column_diff.columns_missing_in_target_db if self.column_diff else _EMPTY_TUPLE

    @property
    def columns_with_distinct_data_type(self) -> Tuple[DBColumnDiff, ...]:
        return self.column_diff.columns_with_distinct_data_type if self.column_diff else _EMPTY_TUPLE

    @property
    def constraints_missing_in_source_db(self) -> Tuple[str, ...]:
        return self.constraint_diff.names_missing_in_source_db if self.constraint_diff else _EMPTY_TUPLE

    @property
    def constraints_missing_in_target_db(self) -> Tuple[str, ...]:
        return self.constraint_diff.names_missing_in_target_db if self.constraint_diff else _EMPTY_TUPLE

    @property
    def indexes_missing_in_source_db(self) -> Tuple[str, ...]:
        return self.index_diff.names_missing_in_source_db if self.index_diff else _EMPTY_TUPLE

    @property
    def indexes_missing_in_target_db(self) -> Tuple[str, ...]:
        return self.index_diff.names_missing_in_target_db if self.index_diff else _EMPTY_TUPLE

 
class DBTablesDiff:

    def __init__(self, source_schema: DBSchema, target_schema: DBSchema) -> None:
        self._source_db_tables = {}
        for table in source_schema.tables:
            self._source_db_tables[table.name] = table

        self._target_db_tables = {}
        for table in target_schema.tables:
            self._target_db_tables[table.name] = table

    def tables_missing_in_source_db(self) -> Tuple[str, ...]:
        source_tables = set(self._source_db_tables.keys())
        target_tables = set(self._target_db_tables.keys())
        return tuple(target_tables - source_tables)

    def number_of_tables_missing_in_source_db(self) -> int:
        return len(self.tables_missing_in_source_db())

    def tables_missing_in_target_db(self) -> Tuple[str, ...]:
        source_tables = set(self._source_db_tables.keys())
        target_tables = set(self._target_db_tables.keys())
        return tuple(source_tables - target_tables)

    def number_of_tables_missing_in_target_db(self) -> int:
        return len(self.tables_missing_in_target_db())

    def tables_with_incompatible_columns(self) -> Tuple[DBTableDiff, ...]:
        result = []
        for table_name in self._common_tables():
            table_diff = self._compare_tables(self._source_db_tables[table_name], self._target_db_tables[table_name])
            if table_diff and table_diff.has_column_discrepancies():
                result.append(table_diff)
        return tuple(result)

    def number_of_tables_with_incompatible_columns(self) -> int:
        return len(self.tables_with_incompatible_columns())

    def tables_with_incompatible_indexes(self) -> Tuple[DBTableDiff, ...]:
        result = []
        for table_name in self._common_tables():
            table_diff = self._compare_tables(self._source_db_tables[table_name], self._target_db_tables[table_name])
            if table_diff and table_diff.has_index_discrepancies():
                result.append(table_diff)
        return tuple(result)

    def number_of_tables_with_incompatible_indexes(self) -> int:
        return len(self.tables_with_incompatible_indexes())

    def tables_with_incompatible_constraints(self) -> Tuple[DBTableDiff, ...]:
        result = []
        for table_name in self._common_tables():
            table_diff = self._compare_tables(self._source_db_tables[table_name], self._target_db_tables[table_name])
            if table_diff and table_diff.has_constraint_discrepancies():
                result.append(table_diff)
        return tuple(result)

    def number_of_tables_with_incompatible_constraints(self) -> int:
        return len(self.tables_with_incompatible_constraints())

    def _common_tables(self) -> Tuple[str, ...]:
        source_tables = set(self._source_db_tables.keys())
        target_tables = set(self._target_db_tables.keys())
        return tuple(source_tables.intersection(target_tables))

    def _compare_columns(self, source_table: DBTable, target_table: DBTable) -> Optional[DBTableColumnsDiff]:
        source_column_names = source_table.column_names_as_set
        target_column_names = target_table.column_names_as_set
        columns_missing_in_source_db = target_column_names - source_column_names
        columns_missing_in_target_db = source_column_names - target_column_names

        source_columns = source_table.columns_as_dict
        target_columns = target_table.columns_as_dict
        distinct_type_columns = []
        for column_name in source_column_names.intersection(target_column_names):
            source_column = source_columns[column_name]
            target_column = target_columns[column_name]
            if str(source_column.datatype) != str(target_column.datatype):
                distinct_type_columns.append(DBColumnDiff(
                    name=column_name,
                    source_data_type=source_column.datatype,
                    target_data_type=target_column.datatype,
                ))

        if len(columns_missing_in_source_db) == 0 and len(columns_missing_in_target_db) == 0 and len(distinct_type_columns) == 0:
            return None

        return DBTableColumnsDiff(
            columns_missing_in_source_db=tuple(columns_missing_in_source_db),
            columns_missing_in_target_db=tuple(columns_missing_in_target_db),
            columns_with_distinct_data_type=tuple(distinct_type_columns),
        )

    def _compare_tables(self, source_table: DBTable, target_table: DBTable) -> Optional[DBTableDiff]:
        assert source_table.name == target_table.name
        column_diff = self._compare_columns(source_table, target_table)
        constraint_diff = self._compare_constraints(source_table, target_table)
        index_diff = self._compare_indexes(source_table, target_table)

        if column_diff or constraint_diff or index_diff:
            return DBTableDiff(
                name=source_table.name,
                column_diff=column_diff,
                constraint_diff=constraint_diff,
                index_diff=index_diff
            )
        else:
            return None

    def _compare_constraints(self, source_table: DBTable, target_table: DBTable) -> Optional[DBTableEnhancementsDiff]:
        source_constraint_names = source_table.constraint_names_as_set
        target_constraint_names = target_table.constraint_names_as_set
        constraints_missing_in_source_db = target_constraint_names - source_constraint_names
        constraints_missing_in_target_db = source_constraint_names - target_constraint_names

        if len(constraints_missing_in_source_db) == 0 and len(constraints_missing_in_target_db) == 0:
            return None

        return DBTableEnhancementsDiff(
            names_missing_in_source_db=tuple(constraints_missing_in_source_db),
            names_missing_in_target_db=tuple(constraints_missing_in_target_db),
        )

    def _compare_indexes(self, source_table: DBTable, target_table: DBTable) -> Optional[DBTableEnhancementsDiff]:
        source_index_names = source_table.index_names_as_set
        target_index_names = target_table.index_names_as_set
        indexes_missing_in_source_db = target_index_names - source_index_names
        indexes_missing_in_target_db = source_index_names - target_index_names

        if len(indexes_missing_in_source_db) == 0 and len(indexes_missing_in_target_db) == 0:
            return None
 
        return DBTableEnhancementsDiff(
            names_missing_in_source_db=tuple(indexes_missing_in_source_db),
            names_missing_in_target_db=tuple(indexes_missing_in_target_db),
        )


class _NamesDiff:

    def __init__(self, source_names: Sequence[str], target_names: Sequence[str]) -> None:
        self._source_names = set(source_names)
        self._target_names = set(target_names)

    def names_missing_in_source_db(self) -> Tuple[str, ...]:
        return tuple(self._target_names - self._source_names)

    def number_of_names_missing_in_source_db(self) -> int:
        return len(self.names_missing_in_source_db())

    def names_missing_in_target_db(self) -> Tuple[str, ...]:
        return tuple(self._source_names - self._target_names)

    def number_of_names_missing_in_target_db(self) -> int:
        return len(self.names_missing_in_target_db())


class DBSchemaDiff:

    def __init__(self, source_schema: DBSchema, target_schema: DBSchema) -> None:
        self._tables_diff = DBTablesDiff(source_schema, target_schema)
        self._sequences_diff = _NamesDiff(source_schema.sequences, target_schema.sequences)
        self._views_diff = _NamesDiff(source_schema.views, target_schema.views)
        self._materialized_views_diff = _NamesDiff(source_schema.materialized_views, target_schema.materialized_views)

    def tables_missing_in_source_db(self) -> Tuple[str, ...]:
        return self._tables_diff.tables_missing_in_source_db()

    def number_of_tables_missing_in_source_db(self) -> int:
        return self._tables_diff.number_of_tables_missing_in_source_db()

    def tables_missing_in_target_db(self) -> Tuple[str, ...]:
        return self._tables_diff.tables_missing_in_target_db()

    def number_of_tables_missing_in_target_db(self) -> int:
        return self._tables_diff.number_of_tables_missing_in_target_db()

    def tables_with_incompatible_columns(self) -> Tuple[DBTableDiff, ...]:
        return self._tables_diff.tables_with_incompatible_columns()

    def number_of_tables_with_incompatible_columns(self) -> int:
        return self._tables_diff.number_of_tables_with_incompatible_columns()

    def tables_with_incompatible_constraints(self) -> Tuple[DBTableDiff, ...]:
        return self._tables_diff.tables_with_incompatible_constraints()

    def number_of_tables_with_incompatible_constraints(self) -> int:
        return self._tables_diff.number_of_tables_with_incompatible_constraints()

    def tables_with_incompatible_indexes(self) -> Tuple[DBTableDiff, ...]:
        return self._tables_diff.tables_with_incompatible_indexes()

    def number_of_tables_with_incompatible_indexes(self) -> int:
        return self._tables_diff.number_of_tables_with_incompatible_indexes()

    def sequences_missing_in_source_db(self) -> Tuple[str, ...]:
        return self._sequences_diff.names_missing_in_source_db()

    def number_of_sequences_missing_in_source_db(self) -> int:
        return self._sequences_diff.number_of_names_missing_in_source_db()

    def sequences_missing_in_target_db(self) -> Tuple[str, ...]:
        return self._sequences_diff.names_missing_in_target_db()
 
    def number_of_sequences_missing_in_target_db(self) -> int:
        return self._sequences_diff.number_of_names_missing_in_target_db()

    def views_missing_in_source_db(self) -> Tuple[str, ...]:
        return self._views_diff.names_missing_in_source_db()

    def number_of_views_missing_in_source_db(self) -> int:
        return self._views_diff.number_of_names_missing_in_source_db()

    def views_missing_in_target_db(self) -> Tuple[str, ...]:
        return self._views_diff.names_missing_in_target_db()

    def number_of_views_missing_in_target_db(self) -> int:
        return self._views_diff.number_of_names_missing_in_target_db()

    def materialized_views_missing_in_source_db(self) -> Tuple[str, ...]:
        return self._materialized_views_diff.names_missing_in_source_db()

    def number_of_materialized_views_missing_in_source_db(self) -> int:
        return self._materialized_views_diff.number_of_names_missing_in_source_db()

    def materialized_views_missing_in_target_db(self) -> Tuple[str, ...]:
        return self._materialized_views_diff.names_missing_in_target_db()

    def number_of_materialized_views_missing_in_target_db(self) -> int:
        return self._materialized_views_diff.number_of_names_missing_in_target_db()
