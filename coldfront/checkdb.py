import sys
from django.db import connections
from django.db.utils import OperationalError
db_conn = connections['default']
try:
    c = db_conn.cursor()
except OperationalError:
    sys.exit(1)
else:
    sys.exit(0)
