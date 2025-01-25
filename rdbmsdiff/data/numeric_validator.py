from dataclasses import dataclass
from typing import Optional

from sqlalchemy import text
from sqlalchemy.orm import Session

from rdbmsdiff.foundation import Configuration, DatabaseProperties, DBColumn, DBTable
from .abstract_validator import AbstractValidator


@dataclass(frozen=True, slots=True)
class _SelectResult:
    min: Optional[float]
    max: Optional[float]
    avg: Optional[float]
    sum: Optional[float]


class NumericValidator(AbstractValidator):

    def __init__(self, config: Configuration, table: DBTable, column: DBColumn) -> None:
        super().__init__(config, table, column)

    def validate(self) -> None:
        source_result = self._select(self.source_db_config)
        print(f"Source: {source_result}")
        target_result = self._select(self.target_db_config)
        print(f"Target: {target_result}")

    def _select(self, db_properties: DatabaseProperties) -> _SelectResult:
        engine = self.create_engine(db_properties)
        with Session(engine) as session:
            statement = f"SELECT MIN({self.column_name}), MAX({self.column_name}), AVG({self.column_name}), SUM({self.column_name}) FROM {self.table_name}"
            print(statement)
            result = session.execute(text(statement)).first()
            return _SelectResult(min=result[0], max=result[1], avg=result[2], sum=result[3])
