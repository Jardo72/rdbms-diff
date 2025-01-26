from enum import Enum
from enum import auto, unique
from sqlalchemy import text
from sqlalchemy.orm import Session

from rdbmsdiff.foundation import Configuration, DatabaseProperties, DBColumn, DBTable
from .abstract_validator import AbstractValidator
from .validation_details import ValidationQuery


@unique
class NullValueCheckType(Enum):
    IS_NULL = auto()
    IS_NOT_NULL = auto()


class NullValueCountValidator(AbstractValidator):

    def __init__(self, config: Configuration, table: DBTable, column: DBColumn, check_type: NullValueCheckType) -> None:
        super().__init__(config, table, column)
        self._check_type = check_type

    def _select(self, db_properties: DatabaseProperties) -> ValidationQuery:
        engine = self.create_engine(db_properties)
        with Session(engine) as session:
            condition = "IS NULL" if self._check_type is NullValueCheckType.IS_NULL else "IS NOT NULL"
            statement = f"SELECT COUNT(*) FROM {self.table_name} WHERE {self.column_name} {condition}"
            result = session.execute(text(statement)).first()
            return ValidationQuery(
                sql=statement,
                result_set=str(result)
            )
