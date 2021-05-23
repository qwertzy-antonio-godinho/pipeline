"""Module with tests written to test the pipeline."""

from example_functionality import Amazing


def test_example_functionality_hola_usecase() -> None:
    """Simple test to confirm happy path."""
    result: int = Amazing().holla()
    expected_result: int = 5
    assert result - 5 == expected_result
