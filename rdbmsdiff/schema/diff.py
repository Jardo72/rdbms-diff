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
    

class DBSchemaDiff:
    ...
