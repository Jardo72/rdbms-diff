
from rdbmsdiff.foundation import Configuration, DBColumn, DBTable

from .abstract_validator import AbstractValidator


class VarcharValidator(AbstractValidator):

    def __init__(self, config: Configuration, table: DBTable, column: DBColumn) -> None:
        super().__init__(config, table, column)

    def validate(self) -> None:
        # engine = self.create_engine(db_properties)
        ...
