from .validation_details import TableValidationDetails


class Report:

    def __init__(self, filename: str) -> None:
        self._file = open(filename, "w")

    def add(details: TableValidationDetails) -> None:
        ...

    def close(self) -> None:
        self._file.close()
