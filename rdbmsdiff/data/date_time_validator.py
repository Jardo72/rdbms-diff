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
            result = session.execute(text(statement)).all()
            return ValidationQuery(
                sql=statement,
                result_set=self.format_rows(result)
            )
