from dataclasses import dataclass
from typing import Any, Optional, Tuple


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
class DBTableConstraintsDiff:
    constraints_missing_in_source_db: Tuple[str, ...]
    constraints_missing_in_target_db: Tuple[str, ...]

    def is_empty(self) -> bool:
        return (
            len(self.constraints_missing_in_source_db) == 0 and
            len(self.constraints_missing_in_target_db) == 0
        )
    

@dataclass(frozen=True, slots=True)
class DBTableIndexesDiff:
    indexes_missing_in_source_db: Tuple[str, ...]
    indexes_missing_in_target_db: Tuple[str, ...]

    def is_empty(self) -> bool:
        return (
            len(self.indexes_missing_in_source_db) == 0 and
            len(self.indexes_missing_in_target_db) == 0
        )
    

_EMPTY_TUPLE = tuple()


@dataclass(frozen=True, slots=True)
class DBTableDiff:
    name: str
    column_diff: Optional[DBTableColumnsDiff]
    constraint_diff: Optional[DBTableConstraintsDiff]
    index_diff: Optional[DBTableIndexesDiff]

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
        return self.constraint_diff.constraints_missing_in_source_db if self.constraint_diff else _EMPTY_TUPLE

    @property
    def constraints_missing_in_target_db(self) -> Tuple[str, ...]:
        return self.constraint_diff.constraints_missing_in_target_db if self.constraint_diff else _EMPTY_TUPLE

    @property
    def indexes_missing_in_source_db(self) -> Tuple[str, ...]:
        return self.index_diff.indexes_missing_in_source_db if self.index_diff else _EMPTY_TUPLE

    @property
    def indexes_missing_in_target_db(self) -> Tuple[str, ...]:
        return self.index_diff.indexes_missing_in_target_db if self.index_diff else _EMPTY_TUPLE

 
class DBSchemaDiff:
    ...
