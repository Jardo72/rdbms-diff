from sqlalchemy import text
from sqlalchemy.orm import Session

from rdbmsdiff.foundation import Configuration, DatabaseProperties, DBColumn, DBTable
from .abstract_validator import AbstractValidator
from .validation_details import ValidationQuery


class VarcharValueValidator(AbstractValidator):

    def __init__(self, config: Configuration, table: DBTable, column: DBColumn) -> None:
        super().__init__(config, table, column)

    def _select(self, db_properties: DatabaseProperties) -> ValidationQuery:
        engine = self.create_engine(db_properties)
        with Session(engine) as session:
            statement = f"SELECT UPPER(MD5({self.column_name})) FROM {self.table_name} WHERE {self.column_name} IS NOT NULL ORDER BY UPPER(MD5({self.column_name})) COLLATE \"en-US-cp037-x-icu\" ASC LIMIT 50"
            result = session.execute(text(statement)).all()
            return ValidationQuery(
                sql=statement,
                result_set=self.format_rows(result)
            )
