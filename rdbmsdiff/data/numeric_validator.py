from sqlalchemy import text
from sqlalchemy.orm import Session

from rdbmsdiff.foundation import Configuration, DatabaseProperties, DBColumn, DBTable
from .abstract_validator import AbstractValidator
from .validation_details import ValidationQuery


class NumericValidator(AbstractValidator):

    def __init__(self, config: Configuration, table: DBTable, column: DBColumn) -> None:
        super().__init__(config, table, column)

    def _select(self, db_properties: DatabaseProperties) -> ValidationQuery:
        engine = self.create_engine(db_properties)
        with Session(engine) as session:
            statement = f"SELECT MIN({self.column_name}), MAX({self.column_name}), AVG({self.column_name}), SUM({self.column_name}) FROM {self.table_name}"
            print(statement)
            result = session.execute(text(statement)).first()
            return ValidationQuery(
                sql=statement,
                result_set=str(result)
            )
