"""This is a simple module with basic functionality used to create tests."""

__version__ = "0.1.0"


class Amazing:
    """Class Amazing."""

    def holla(self) -> int:
        """Return implicit value."""
        return 10


if __name__ == "__main__":  # pragma: no cover
    test = Amazing()
    print(str(test.holla()))
