from pathlib import Path

from toml import loads

PYPROJECT_PATH = Path(__file__).parent.parent.parent / "pyproject.toml"
version = loads(PYPROJECT_PATH.read_text())["tool"]["poetry"]["version"]
