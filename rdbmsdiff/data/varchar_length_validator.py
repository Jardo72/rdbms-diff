from sqlalchemy import text
from sqlalchemy.orm import Session

from rdbmsdiff.foundation import Configuration, DatabaseProperties, DBColumn, DBTable
from .abstract_validator import AbstractValidator
from .validation_details import ValidationQuery


class VarcharLengthValidator(AbstractValidator):

    def __init__(self, config: Configuration, table: DBTable, column: DBColumn) -> None:
        super().__init__(config, table, column)

    def _select(self, db_properties: DatabaseProperties) -> ValidationQuery:
        engine = self.create_engine(db_properties)
        with Session(engine) as session:
            statement = f"SELECT LENGTH({self.column_name}), COUNT(LENGTH({self.column_name})) FROM {self.table_name} GROUP BY LENGTH({self.column_name}) ORDER BY LENGTH({self.column_name}) ASC"
            result = session.execute(text(statement)).all()
            return ValidationQuery(
                sql=statement,
                result_set=self.format_rows(result)
            )
