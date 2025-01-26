from dataclasses import dataclass
from enum import Enum
from enum import auto, unique


@unique
class ValidationResult(Enum):
    PASSED = auto()
    FAILED = auto()


@dataclass(frozen=True)
class ValidationQuery:
    sql: str
    result_set: str


@dataclass(frozen=True)
class ValidationDetails:
    result: ValidationResult
    validator_description: str
    source_query_details: ValidationQuery
    target_query_details: ValidationQuery
