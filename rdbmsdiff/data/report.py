from .validation_details import ColumnValidationDetails, TableValidationDetails


class Report:

    def __init__(self, filename: str) -> None:
        self._file = open(filename, "w")

    def _write_table_header(self, details: TableValidationDetails) -> None:
        self._file.write(f"{90 * '='}\n")
        self._file.write(f"= {details.table_name}\n")
        self._file.write(f"= Status = {details.result}\n")
        self._file.write(f"{90 * '='}\n")
        self._file.write("\n")

    def _write_column_details(self, details: ColumnValidationDetails) -> None:
        self._file.write(f"{80 * '-'}\n")
        self._file.write(f"- {details.validator_description}\n")
        self._file.write(f"{80 * '-'}\n")
        self._file.write(f"Status: {details.result}")
        self._file.write("\n")
        self._file.write("Source DB\n")
        self._file.write(f"SQL: {details.source_query_details.sql}\n")
        self._file.write("Result-set:\n")
        self._file.write(details.source_query_details.result_set)
        self._file.write("\n")
        self._file.write("Target DB\n")
        self._file.write(f"SQL: {details.target_query_details.sql}\n")
        self._file.write("Result-set:\n")
        self._file.write(details.target_query_details.result_set)
        self._file.write("\n")

    def add(self, table_details: TableValidationDetails) -> None:
        self._write_table_header(table_details)
        for column_details in table_details.column_validations_details:
            self._write_column_details(column_details)

    def close(self) -> None:
        self._file.close()
