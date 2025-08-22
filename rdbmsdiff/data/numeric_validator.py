#
# Copyright 2025 Jaroslav Chmurny
#
# This file is part of RDBMS Diff.
#
# RDBMS Diff is free software licensed under the Apache License,
# Version 2.0 (the "License"); you may not use this file except in
# compliance with the License. You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

from sqlalchemy import text
from sqlalchemy.orm import Session

from rdbmsdiff.foundation import (
    Configuration,
    DatabaseProperties,
    DBColumn,
    DBTable,
)
from .abstract_validator import AbstractValidator
from .validation_details import ValidationQuery


class NumericValidator(AbstractValidator):

    def __init__(self, config: Configuration, table: DBTable, column: DBColumn) -> None:
        super().__init__(config, table, column)

    def _select(self, db_properties: DatabaseProperties) -> ValidationQuery:
        engine = self.create_engine(db_properties)
        with Session(engine) as session:
            statement = f"SELECT MIN({self.column_name}), MAX({self.column_name}), AVG({self.column_name}), SUM({self.column_name}) FROM {self.table_name}"
            result = session.execute(text(statement)).first()
            return ValidationQuery(
                sql=statement,
                result_set=str(result)
            )
