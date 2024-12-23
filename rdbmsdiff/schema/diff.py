from dataclasses import dataclass
from typing import Any, Optional, Sequence, Set, Tuple

from rdbmsdiff.schema import DBSchema


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

 
class _NamesDiff:

    def __init__(self, source_names: Sequence[str], target_names: Sequence[str]) -> None:
        self._source_names = set(source_names)
        self._target_names = set(target_names)

    def names_missing_in_source_db(self) -> Tuple[str, ...]:
        return tuple(self._target_names - self._source_names)

    def number_of_names_missing_in_source_db(self) -> int:
        return len(self.names_missing_in_source_db())

    def names_missing_in_target_db(self) -> Tuple[str, ...]:
        return tuple(self._source_names - self._source_names)

    def number_of_names_missing_in_target_db(self) -> int:
        return len(self.names_missing_in_target_db())


class DBSchemaDiff:

    def __init__(self, source_schema: DBSchema, target_schema: DBSchema) -> None:
        self._sequences_diff = _NamesDiff(source_schema.sequences, target_schema.sequences)
        self._views_diff = _NamesDiff(source_schema.views, target_schema.views)
        self._materialized_views_diff = _NamesDiff(source_schema.materialized_views, target_schema.materialized_views)

    def sequences_missing_in_source_db(self) -> Tuple[str, ...]:
        return self._sequences_diff.names_missing_in_source_db()

    def number_of_sequences_missing_in_source_db(self) -> int:
        return self._sequences_diff.number_of_names_missing_in_source_db()

    def sequences_missing_in_target_db(self) -> Tuple[str, ...]:
        return self._sequences_diff.names_missing_in_target_db()
 
    def number_of_sequences_missing_in_target_db(self) -> int:
        return self._sequences_diff.names_missing_in_target_db()

    def views_missing_in_source_db(self) -> Tuple[str, ...]:
        return self._views_diff.names_missing_in_source_db()

    def number_of_views_missing_in_source_db(self) -> int:
        return self._views_diff.number_of_names_missing_in_source_db()

    def views_missing_in_target_db(self) -> Tuple[str, ...]:
        return self._views_diff.names_missing_in_target_db()

    def number_of_views_missing_in_target_db(self) -> int:
        return self._views_diff.number_of_names_missing_in_target_db()
