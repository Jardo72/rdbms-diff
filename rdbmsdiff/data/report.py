from .validation_details import ColumnValidationDetails, TableValidationDetails


class Report:

    def __init__(self, filename: str) -> None:
        self._file = open(filename, "w")

    def _write_table_header(self, details: TableValidationDetails) -> None:
        self._file.write(f"{90 * '='}\n")
        self._file.write(f"= Table:  {details.table_name}\n")
        self._file.write(f"= Status: {details.result.name} ({details.failed_validation_count} of {details.overall_validation_count} validations failed)\n")
        self._file.write(f"{90 * '='}\n")
        self._file.write("\n")

    def _write_column_validation_details(self, details: ColumnValidationDetails) -> None:
        self._file.write(f"{80 * '-'}\n")
        self._file.write(f"- {details.validator_description}\n")
        self._file.write(f"{80 * '-'}\n")
        self._file.write(f"Status: {details.result.name}\n\n")
        self._file.write("Source DB\n")
        self._file.write(f"SQL: {details.source_query_details.sql}\n")
        self._file.write("Result-set:\n")
        self._file.write(details.source_query_details.result_set)
        self._file.write("\n\n")
        self._file.write("Target DB\n")
        self._file.write(f"SQL: {details.target_query_details.sql}\n")
        self._file.write("Result-set:\n")
        self._file.write(details.target_query_details.result_set)
        self._file.write("\n\n")

    def add(self, table_details: TableValidationDetails) -> None:
        self._write_table_header(table_details)
        for column_details in table_details.column_validations_details:
            self._write_column_validation_details(column_details)

    def close(self) -> None:
        self._file.close()
