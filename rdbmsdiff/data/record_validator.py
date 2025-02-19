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

from rdbmsdiff.foundation import Configuration, DatabaseProperties, DBTable
from .abstract_validator import AbstractValidator
from .validation_details import ValidationQuery


class RecordValidator(AbstractValidator):

    def __init__(self, config: Configuration, table: DBTable) -> None:
        super().__init__(config, table, None)

    def _select(self, db_properties: DatabaseProperties) -> ValidationQuery:
        if not self.table.has_primary_key:
            return ValidationQuery(sql="N/A", result_set="N/A")

        columns = ""
        for column in self.table.primary_key_constraints[0].columns:
            if columns:
                columns += ", "
            columns += f"{column} ASC"
        engine = self.create_engine(db_properties)
        with Session(engine) as session:
            # TODO: we should not involve LOB columns (BLOB, CLOB, TEXT, BYTEA etc.)
            statement = f"SELECT * FROM {self.table_name} ORDER BY {columns} LIMIT {self.limit}"
            result = session.execute(text(statement)).all()
            return ValidationQuery(
                sql=statement,
                result_set=self.format_rows(result)
            )
