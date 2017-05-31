import hashlib
import sys

uid = 0

for name in sys.stdin:
    name = name.strip()
    uid += 1
    score = 5
    role = 1
    password = hashlib.sha256(name.encode("utf-8")).hexdigest()
    print("%d\t%d\t%d\t%s\t%s" % (
        uid, score, role, name, password
    ))
