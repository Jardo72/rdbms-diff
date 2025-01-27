from dataclasses import dataclass
from enum import Enum
from enum import auto, unique
from typing import Tuple


@unique
class ValidationResult(Enum):
    PASSED = auto()
    FAILED = auto()


@dataclass(frozen=True)
class ValidationQuery:
    sql: str
    result_set: str


@dataclass(frozen=True)
class ColumnValidationDetails:
    result: ValidationResult
    validator_description: str
    source_query_details: ValidationQuery
    target_query_details: ValidationQuery


@dataclass(frozen=True)
class TableValidationDetails:
    table_name: str
    column_validations_details: Tuple[ColumnValidationDetails, ...]
