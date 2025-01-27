from sqlalchemy import text
from sqlalchemy.orm import Session

from rdbmsdiff.foundation import Configuration, DatabaseProperties, DBColumn, DBTable
from .abstract_validator import AbstractValidator
from .validation_details import ValidationQuery


class DateTimeValidator(AbstractValidator):

    def __init__(self, config: Configuration, table: DBTable, column: DBColumn) -> None:
        super().__init__(config, table, column)

    def _get_format_pattern(self) -> str:
        if self.column.is_date:
            return "YYYY-MM-DD"
        elif self.column.is_time:
            return "HH24:MI:SS"
        elif self.column.is_timestamp:
            return "YYYY-MM-DD HH24:MI:SS"
        else:
            raise ValueError(f"Unexpected column type: {self._column_type}")

    def _select(self, db_properties: DatabaseProperties) -> ValidationQuery:
        engine = self.create_engine(db_properties)
        with Session(engine) as session:
            format_pattern = self._get_format_pattern()
            statement = f"SELECT TO_CHAR({self.column_name}, '{format_pattern}') FROM {self.table_name} WHERE {self.column_name} IS NOT NULL ORDER BY TO_CHAR({self.column_name}, '{format_pattern}') ASC LIMIT {self.limit}"
            result = session.execute(text(statement)).first()
            return ValidationQuery(
                sql=statement,
                result_set=self.format_rows(result)
            )
