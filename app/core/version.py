from pathlib import Path

from toml import loads

version = loads(Path("pyproject.toml").read_text())["tool"]["poetry"]["version"]
