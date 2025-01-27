from abc import ABC
from abc import abstractmethod
from concurrent.futures import ThreadPoolExecutor
from typing import Any, Sequence

from sqlalchemy import create_engine
from sqlalchemy import Engine, MetaData
from sqlalchemy.engine import Row

from rdbmsdiff.foundation import Configuration, DatabaseProperties, DBColumn, DBTable

from .validation_details import ColumnValidationDetails, ValidationQuery, ValidationResult


class AbstractValidator(ABC):

    _EXECUTOR = ThreadPoolExecutor(max_workers=2)

    def __init__(self, config: Configuration, table: DBTable, column: DBColumn) -> None:
        self._source_db_config = config.source_db_config
        self._target_db_config = config.target_db_config
        self._table = table
        self._column = column

    def create_engine(self, db_properties: DatabaseProperties) -> Engine:
        engine = create_engine(url=db_properties.url_with_password)
        meta_data = MetaData(schema=db_properties.schema)
        meta_data.reflect(bind=engine)
        return engine

    @property
    def limit(self) -> int:
        return 50

    @property
    def source_db_config(self) -> DatabaseProperties:
        return self._source_db_config

    @property
    def target_db_config(self) -> DatabaseProperties:
        return self._target_db_config

    @property
    def table_name(self) -> str:
        return self._table.name

    @property
    def column(self) -> DBColumn:
        return self._column

    @property
    def column_name(self) -> str:
        return self._column.name

    @property
    def description(self) -> str:
        return f"{self._table.name}.{self._column.name} - {type(self).__name__}"

    def validate(self) -> ColumnValidationDetails:
        source_query_future = self._EXECUTOR.submit(self._select, self.source_db_config)
        target_query_future = self._EXECUTOR.submit(self._select, self.target_db_config)
        source_query_details = source_query_future.result()
        target_query_details = target_query_future.result()
        return ColumnValidationDetails(
            result=ValidationResult.PASSED if source_query_details.result_set == target_query_details.result_set else ValidationResult.FAILED,
            validator_description=self.description,
            source_query_details=source_query_details,
            target_query_details=target_query_details,
        )

    @abstractmethod
    def _select(self, db_properties: DatabaseProperties) -> ValidationQuery:
        ...

    @staticmethod
    def format_rows(rows: Sequence[Row[Any]]) -> str:
        if not rows:
            return "N/A"
        result = ""
        for single_row in rows:
            result += str(single_row) + "\n"
        result += "\n"
        return result
