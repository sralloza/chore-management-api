import sys
from pathlib import Path
from time import sleep

from pymysql.err import OperationalError

sys.path.insert(0, Path(__file__).parent.parent.as_posix())
from app.db.init_database import init_db_sync

if __name__ == "__main__":
    for _ in range(10):
        try:
            init_db_sync()
            break
        except OperationalError as e:
            print(e)
            sleep(1)
            continue
