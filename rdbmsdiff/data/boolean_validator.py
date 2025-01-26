from sqlalchemy.orm import Session

from rdbmsdiff.foundation import Configuration, DatabaseProperties, DBColumn, DBTable
from .abstract_validator import AbstractValidator
from .validation_details import ValidationQuery


class BooleanValidator(AbstractValidator):

    def __init__(self, config: Configuration, table: DBTable, column: DBColumn) -> None:
        super().__init__(config, table, column)

    def _select(self, db_properties: DatabaseProperties) -> ValidationQuery:
        engine = self.create_engine(db_properties)
        with Session(engine) as session:
            ...
