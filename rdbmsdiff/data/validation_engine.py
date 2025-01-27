from typing import Tuple

from rdbmsdiff.foundation import Configuration, DBSchema, DBTable

from .abstract_validator import AbstractValidator
from .boolean_validator import BooleanValidator
from .null_value_count_validator import NullValueCheckType, NullValueCountValidator
from .numeric_validator import NumericValidator
from .report import Report
from .validation_details import ColumnValidationDetails, TableValidationDetails
from .varchar_length_validator import VarcharLengthValidator


class ValidationEngine:

    def __init__(self, config: Configuration, source_db_meta_data: DBSchema, target_db_meta_data: DBSchema, report: Report):
        self._config = config
        self._source_db_meta_data = source_db_meta_data
        self._target_db_meta_data = target_db_meta_data
        self._report = report

    def _create_validators(self, table: DBTable) -> Tuple[AbstractValidator, ...]:
        result = []
        for column in table.columns:
            if column.is_numeric:
                result.append(NumericValidator(self._config, table, column))
            elif column.is_string:
                result.append(VarcharLengthValidator(self._config, table, column))
            elif column.is_boolean:
                result.append(BooleanValidator(self._config, table, column))
            if column.nullable:
                result.append(NullValueCountValidator(self._config, table, column, NullValueCheckType.IS_NULL))
                result.append(NullValueCountValidator(self._config, table, column, NullValueCheckType.IS_NOT_NULL))
        return tuple(result)

    def _validate_single_table(self, table: DBTable) -> TableValidationDetails:
        print(f"Going to validate the table {table.name}")
        validators = self._create_validators(table)
        details = []
        for validator in validators:
            column_validation_details = validator.validate()
            details.append(column_validation_details)
        return TableValidationDetails(table.name, tuple(details))

    def validate(self) -> None:
        for table in self._source_db_meta_data.tables:
            # TODO: check if the table is present in the target DB
            details = self._validate_single_table(table)
            self._report.add(details)
