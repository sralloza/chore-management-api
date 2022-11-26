import sys
from pathlib import Path
sys.path.insert(0, Path(__file__).parent.parent.as_posix())
from app.db.init_database import init_db_sync

init_db_sync()
