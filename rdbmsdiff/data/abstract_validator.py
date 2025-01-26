from abc import ABC
from abc import abstractmethod

from sqlalchemy import create_engine
from sqlalchemy import MetaData

from rdbmsdiff.foundation import Configuration, DatabaseProperties, DBColumn, DBTable

from .validation_details import ValidationDetails, ValidationQuery, ValidationResult


class AbstractValidator(ABC):

    def __init__(self, config: Configuration, table: DBTable, column: DBColumn) -> None:
        self._source_db_config = config.source_db_config
        self._target_db_config = config.target_db_config
        self._table = table
        self._column = column

    def create_engine(self, db_properties: DatabaseProperties):
        engine = create_engine(url=db_properties.url_with_password)
        meta_data = MetaData(schema=db_properties.schema)
        meta_data.reflect(bind=engine)
        return engine

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
    def column_name(self) -> str:
        return self._column.name

    @property
    def description(self) -> str:
        return f"{self._table.name}.{self._column.name} - {type(self).__name__}"

    def validate(self) -> ValidationDetails:
        source_query_details = self._select(self.source_db_config)
        target_query_details = self._select(self.target_db_config)
        return ValidationDetails(
            result=ValidationResult.PASSED if source_query_details.result_set == target_query_details.result_set else ValidationResult.FAILED,
            source_query_details=source_query_details,
            target_query_details=target_query_details,
        )

    @abstractmethod
    def _select(self, db_properties: DatabaseProperties) -> ValidationQuery:
        ...
